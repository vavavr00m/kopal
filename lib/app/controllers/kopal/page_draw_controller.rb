class Kopal::PageDrawController < Kopal::ApplicationController
  helper Kopal::Helper::PageDrawHelper

# params[:page_id] has preference over params[:page].
#
#LATER: Remove inline JavaScript.
#LATER: Make current profile pages as "Social Profile", "Interests" etc. as page
#widgets under section "Add widget -> Profile ". Users can also create their own
#page widgets which display a profile of the user on a particular subject.
#
#LATER: Add element - "Table".


	before_filter :authorise, :page_draw_init
  before_filter :initialise_atpage, :except =>
                  ['index', 'create_page', 'create_example_page']

  def index
    redirect_to Kopal.route.page
  end

  def create_page
    title = "new-page"
    p = Kopal::ProfilePage.recursively_assign_page_name title
    p.save!
    redirect_to Kopal.route.page_edit :page => p.page_name
  end

  def rename_page
    if request.post?
      old_name = @page.page_name
      @page.page_name = params[:page_name]
      if @page.save
        flash[:highlight] = "Renamed page."
        redirect_to Kopal.route.page_draw :action => 'edit', :page => @page.to_s
        return
      end
      @page.page_name = old_name
    end
  end

	#LATER: In lists a option - View this list as numbered, with bullets/squares, nothing (default)
	def edit
		redirect_to :action => 'index' and return if params[:page].blank?
    @_page.title = [params[:page], "Edit Page"]
		@already_present_elements = ''
    @page.elements.each { |e|
      e[:'heading'] = 'Click to edit heading' if e[:'heading'].blank?
      @already_present_elements << render_element_to_string(e)
    }
	end

	#LATER: all these methods to one method insert_element
	def insert_element_text
		element = {}
		element[:'type'] = 'text'
		element[:'heading'] = 'Heading for note'
		element[:'text'] = 'New text note'
		create_and_render_element element
	end

	def insert_element_list
		element = {}
		element[:'type'] = 'list'
		element[:'heading'] = 'My List —'
		element[:'entry'] = ['New list element', 'New list element']
		create_and_render_element element
	end

	def insert_element_pair
		element = {}
		element[:'type'] = 'pair'
		element[:'heading'] = 'My Profile —'
		element[:'entry'] = [ {:'heading' => 'This is heading', :'text' => 'This is the text'},
			{:'heading' => 'This is another heading', :'text' => "This is another text \n in multiple lines."}
			]
		create_and_render_element element
	end

	def insert_element_todo
		element = {}
		element[:'type'] = 'todo'
		element[:'heading'] = 'My to-dos'
		element[:'entry'] = [ {:'text' => 'My to-do element', :'status' => 'active'},
      {:'text' => 'another to-do element', :'status' => 'done'} ]
		create_and_render_element element
	end

	def insert_element_separator
		element = {}
		element[:'type'] = 'separator'
		element[:'heading'] = 'Separator'
		create_and_render_element element
	end

	#LATER: All these methods to one method - insert_element_child
	def insert_list_element
    @element = @page.page_text[:element][params[:element_id].to_i]
		return unless @element and @element[:'type'] == 'list'
		@element[:entry] << 'New list element'
		@page.save!
    render :action => 'insert_child_element'
	end

	def insert_pair_element
		@element = @page.page_text[:element][params[:element_id].to_i]
		return unless @element and @element[:type] == 'pair'
    @element[:entry] << { :'heading' => :'Element heading',
        :'text' => 'Element text' }
		@page.save!
		render :action => 'insert_child_element'
	end

	def insert_todo_element
		@element = @page.page_text[:element][params[:element_id].to_i]
		return unless @element and @element[:'type'] == 'todo'
		@element[:entry] << { :'text' => 'New to-do', :'status' => 'active' }
		@page.save!
    render :action => 'insert_child_element'
	end

	def save_element_heading #Common for all elements
		#This is assumed that all elements have a field - heading
		@page.page_text[:element][params[:id].to_i][:'heading'] = params[:value]
		@page.save!
		@heading = params[:value].blank?() ? '[Click to edit heading]' : params[:value]
		render :inline => "<%= h @heading %>"
	end

	def save_element_child
		return if params[:type].blank?
		@element = @page.page_text[:element][params[:element_id].to_i]
		@child_index = params[:child_index].to_i
		return unless @element[:'type'] == params[:type] #sign_error()
		@to_render = case params[:type]
			when 'pair':
				if(params[:sub_type] == 'text')
					@element[:'entry'][@child_index][:'text'] = params[:value]
				elsif(params[:sub_type] == 'heading')
					@element[:'entry'][@child_index][:'heading'] = params[:value]
				end
		end
		@page.save!
    @to_render.blank?() ? @to_render = "[Click to edit]" : nil
		render :inline => "<%= params[:sub_type] == 'text' ?
      wikify(@to_render) : h(@to_render) %>"
	end

	#LATER: !DRY at present, integrate all these methods to above method save_element_child
	def save_text_text #Make use of Highlighting
    element = @page.page_text[:element][params[:id].to_i]
		unless element or element[:'type'] == 'text'
			return false
		end
		element[:'text'] = params[:value]
		@page.save!
    @element = element
		render :inline => "<%= wikify @element[:'text'] %>"
	end

	def save_list_element
    @element = @page.page_text[:element][params[:id].to_i]
    @child_index = params[:child_index].to_i
		return false unless @element and @element[:'type'] == 'list' and
      @element[:entry][@child_index]
		@element[:entry][@child_index] = params[:value]
		@page.save!
		render :inline => "<%= wikify @element[:entry][@child_index] %>"
	end

  #Why passing parameters as p1_p2 format? Because back then when I wrote this
  #code (1 year or so), there was a problem with something that more than 1 parameters
  #were passed as p1=v1&amp;p2=v2. so the second paramater was actually params[:"amp;p2"],
  #(or may be because I didn't understand rails much then).
  #This situation doesn't seem to occur now.
	def save_todo_element
		todo_id, @child_index = params[:id].split('_').map { |e| e.to_i}
		@element = @page.page_text[:element][todo_id]
		return unless @element and @element[:'type'] == 'todo' and @element[:entry][@child_index]
		@element[:entry][@child_index][:text] = params[:value]
		@page.save!
		render :inline => "<%= wikify @element[:entry][@child_index][:text] %>"
	end

	def save_todo_element_status
		todo_id, @child_index, @child_status = params[:id].split('_')
    @child_index = @child_index.to_i
		@element = @page.page_text[:element][todo_id.to_i]
    #OPTIMIZE: sign_error() instead of just returning.
		return unless @element and @element[:'type'] == 'todo' and @element[:entry][@child_index]
		@element[:entry][@child_index][:'status'] = @child_status
		@page.save!
	end

	def edit_table
	end

	def delete_element
		@page.delete_element params[:id].to_i
		render :nothing => true
	end

	#Deletes elements of lists, pair and todos
	def delete_element_child
    @element = @page.page_text[:element][params[:element_id].to_i]
    @child_index = params[:child_index].to_i
		unless @element and @element[:entry][params[:child_index].to_i]
			render_status(403) and return
		end
		@element[:entry].delete_at(@child_index)
		@page.save!
	end

	def delete_page
		if request.post?
			if request.xhr?
				unless @page
          flash[:notice] = "Can not find page - #{@page}"
        else
          @page.destroy
          flash[:highlight] = "Page \"#{@page}\" has been deleted."
        end
			else
				# code for deletion without xhr
			end
		end
		redirect_2 Kopal.route.page
	end

	def update_page_description_aj
		return false if params[:value].empty? or !@page
		@page.page_description = params[:value]
    @page.save!
		render :text => @page.page_description
	end

	def sort_element
		unless params[:PageEdit] or params[:PageEdit].instance_of? Array
			return
		end
		@page.page_text[:meta][:sorting_order] = params[:PageEdit].map { |x| x.to_i}
		@page.save
		render :nothing => true
	end

  def create_example_page
    create_example_pages
    redirect_to :action => 'index'
  end

private
	def page_draw_init # May also use initialize() here but has a doubt that will still the action won't execute if it returns false?
    @page = Kopal::ProfilePage.find_by_page_name params[:page] if params[:page]
		@_page.title <<= @page.page_name if @page
    @_page.include_prototype
    @_page.include_scriptaculous
	end

  #initialise @page
  def initialise_atpage
		if params[:page_id]
			page_by_id_exists?
		elsif params[:page]
			page_exists?
		end
    unless @page
      flash[:notice] = "Can not find page - #{@page}"
      redirect_2 Kopal.route.page_draw
      return false
    end
  end

	def page_by_id_exists?
		return if params[:page_id].blank?
		@page = Kopal::ProfilePage.find_by_id(params[:page_id])
	end

	def page_exists?
		return if params[:page].blank?
		@page = Kopal::ProfilePage.find_by_page_name(params[:page])
	end

	def render_element_to_string element
		@element = element #to be used by element_layout.rhtml
		return render_to_string(:action => 'element_layout', :layout => false)
	end

	def create_and_render_element element
		@page.insert_element element
		r = render_element_to_string(element)
		render :update do |page|
			page.insert_html :top, 'PageEdit', r
		end
	end

  def create_example_pages
    #to write
  end

end
