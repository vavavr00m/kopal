#Migrate AMAP code which is not rails-specific to Kopal lib.
class Kopal::PageDrawController < Kopal::ApplicationController

# params[:page_id] has preference over params[:page].
#
#LATER: Remove inline JavaScript.
#LATER: Make current profile pages as "Social Profile", "Interests" etc. as page
#widgets under section "Add widget -> Profile ". Users can also create their own
#page widgets which display a profile of the user on a particular subject.
#Automatically create some example profiles on creation of account.
#
#LATER: Add element - "Table".


	before_filter :authorise, :page_draw_init
  before_filter :initialise_atpage, :except =>
                  ['index', 'create_page', 'create_example_page']

  def index
    redirect_to @kopal_route.page
  end

  #TODO: Shall be POST.
  def create_page
    title = "new-page"
    p = Kopal::ProfilePage.recursively_assign_page_name @profile_user.account.id, title
    p.save!
    redirect_to @kopal_route.page_edit :page => p.page_name
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
		redirect_to :action => 'index' and return if @page.blank?
    @_page.title = [params[:page], "Edit Page"]
	end

  def add_widget
    @page.elements << Kopal::PageWidget.new(:widget_uri => params[:widget_url])
    flash[:highlight] = "Added new widget."
    redirect_to :back
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

	def update_page_description_xhr
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
    @page = @profile_user.account.pages.find_by_page_name params[:page] if params[:page]
		@_page.title <<= @page.page_name if @page
    @_page.include_prototype
    @_page.include_scriptaculous
    @_page.include_yui
    @_page.add_javascript @kopal_route.javascript 'page'
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
      redirect_2 @kopal_route.page_draw
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
