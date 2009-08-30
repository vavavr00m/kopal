module Kopal::Helper::PageDrawHelper

  #Pass arguemnts as -> { :key => 'value' }
	#PARAM: page_id => Database ID of page
	#PARAM: element => the element
	#PARAM: escape_wrapping_with_div => if true, render without the <div id=""> wrapper. default is false
	def render_element hash
		@hash = hash;
		@element_html_id = generate_html_id(@hash[:element][:id])
		@child_wrapper_id = "#{@element_html_id}_Wrap" #For use in list, pair, todo
		
		r = ''
		r << "<div class=\"PageElement\" id=\"#{@element_html_id}\">" unless @hash[:escape_wrapping_with_div]
		r << "<div style=\"text-align:right; padding:0; margin:0;\">"
		r << link_to_remote('Delete', {
			:url => Kopal.route.page_draw({:action => 'delete_element',
          :id => @hash[:element][:id], :page_id => @hash[:page_id]}),
			:before => "kopal.spinner('#{@element_html_id}', 'Top', 'Deleting....');",
			:success => visual_effect(:highlight, @element_html_id, :duration => 2.0) + visual_effect(:fold, @element_html_id),
			:confirm => "Are you sure you want to delete this page element." +
        "This action is irreversible.\n _________________________________ \n #{@hash[:element][:heading]}"
			},
			{
				:title => 'Delete this page element'
			})
		r << '&nbsp;&nbsp;<span style="font-weight:bold;color:#2A2A2A;cursor:move;">Move</span>'
		r << '</div>'
		r << "<span class=\"Heading\" id=\"#{@element_html_id}_Heading\">"
		r << in_place_editor(h(@hash[:element][:heading]), "#{@element_html_id}_Heading",
      Kopal.route.page_draw({:action => 'save_element_heading',
          :id => @hash[:element][:id], :page_id => @hash[:page_id]})
    )
		r << '</span>'
		case @hash[:element][:type].to_s
			when 'text':
				r << render_text_element
			when 'separator':
				r << render_separator_element
			when /^(list|pair|todo)$/:
				r << render_expandable_element
		end
		r << '</div>'
	end
	
	#This method generates an ID for an HTML element.
	#If the 2nd parameter is false, an ID for a page element is generated.
	#If the 2nd parameter is !false, an ID for an element of a page element is generated.
	def generate_html_id element_id, element_child_index = false
		return "E_#{element_id}" unless element_child_index
		return "E_#{element_id}_#{element_child_index}"
	end
	
	def render_text_element
		r = "<p class=\"Text\" id=\"#{@element_html_id}_Text\">"
		r << in_place_editor(wikify(@hash[:element][:text]), "#{@element_html_id}_Text",
      Kopal.route.page_draw({:action => 'save_text_text',
        :id => @hash[:element][:id], :page_id => @hash[:page_id]}),
			{:rows => 8})
		r << '</p>'
	end

	def render_separator_element
		"<span><hr /></span>"
	end
	
	#render_list, render_pair, render_todo had a lot of duplication,
	#so I just created this method instead
	def render_expandable_element
		case @hash[:element][:type]
			when 'list':
				r = "<ul class=\"List\" id=\"#{@child_wrapper_id}\">"
			when 'pair':
				r = "<table><tbody id=\"#{@child_wrapper_id}\">"
			when 'todo':
				r = "<ul id=\"#{@child_wrapper_id}\">"
		end
		
		i = 0
		@hash[:element][:entry].each { |e|
			r << render_element_child(:element => @hash[:element], :child_index => i,
        :page_id => @hash[:page_id], :child => e)
			i = i.next
		}
		case @hash[:element][:type]
			when 'list':
				r << '</ul>'
			when 'pair':
				r << '</tbody></table>'
			when 'todo':
				r << '</ul>'
		end
		
		r << link_to_remote('Add a new element', {
			:url => Kopal.route.page_draw({:action => "insert_#{@hash[:element][:type]}_element",
        :element_id => @hash[:element][:id], :page_id => @hash[:page_id]}),
			:before => "var s = kopal.spinner('#{@child_wrapper_id}', 'After', 'Adding element')",
			:complete => "Element.hide(s)"
			},
			{ :title => 'Insert a new element'})
		
	end

	#PARAM:  {element, page_id, :child_index, :child}
	def render_element_child hash, return_child_html_id = false
		@hash = hash
    @hash[:child_index] ||= @hash[:element][:entry].size
		@element_html_id = generate_html_id(@hash[:element][:id])
		@child_html_id = generate_html_id(@hash[:element][:id], @hash[:child_index])
		@child_wrapper_id = "#{@element_html_id}_Wrap" #The container for example <ul> for list, todo and <tr> for list2
		@child_helper_id = "#{@child_html_id}_Helper"

		@helper_span_start =
      "<span onmouseover=\"$('#{@child_helper_id}').style.visibility = 'visible';" +
      "\" onmouseout=\"$('#{@child_helper_id}').style.visibility = 'hidden';\">"
		@helper_span_close = helper_link + '</span>'

		case @hash[:element][:type]
			when 'list':
				r = render_list_element
			when 'pair':
				r = render_pair_element
			when 'todo':
				r = render_todo_element
		end
		return r unless return_child_html_id
		return r, @child_html_id
	end	
	

	def render_list_element
		r = "<li id=\"#{@child_html_id}\">" + @helper_span_start
		#RAILSBUG: Need to pass :escape => true to make it work correctly. Maybe because it's wrapped in CDATA
		r << in_place_editor(wikify(@hash[:child]), @child_html_id,
					Kopal.route.page_draw({ :action => 'save_list_element', :id => "#{@hash[:element][:id]}",
            :child_index => "#{@hash[:child_index]}", :page_id => @hash[:page_id],
            :escape => false})
				)
		r << @helper_span_close
		r << '</li>'
		return r
	end
	
	#LATER: Move from <table> to <div>
	def render_pair_element
		r = '<tr id="'+ @child_html_id +'">'
		r << '<td valign="top" align="right"><b>'
		r << in_place_editor(h(@hash[:child][:heading]), @child_html_id + '_Heading',
          Kopal.route.page_draw({ :action => 'save_element_child', :type => 'pair',
            :sub_type => 'heading', :element_id => @hash[:element][:id],
            :child_index => @hash[:child_index],
            :page_id => @hash[:page_id], :escape => false })
						)
		r << '</b></td><td>' + @helper_span_start
		r << in_place_editor(wikify(@hash[:child][:text]), @child_html_id + '_Text',
          Kopal.route.page_draw({ :action => 'save_element_child', :type => 'pair',
            :sub_type => 'text', :element_id => @hash[:element][:id],
            :child_index => @hash[:child_index],
            :page_id => @hash[:'page_id'], :escape => false }),
				:rows => 4
						)
		r <<  @helper_span_close + '</td>' + '</tr>'
		return r
	end
	

	def render_todo_element
		new_status = (@hash[:child][:'status'] == 'done' ? 'active' : 'done')
		status_link = Kopal.route.page_draw(:action => 'save_todo_element_status',
      :id => "#{@hash[:element][:id]}_#{@hash[:child_index]}_#{new_status}",
      :page_id => @hash[:'page_id'])
		checked = (@hash[:child][:'status'] == 'done' ? 'checked="checked"' : '')
		r = '<li id="' + @child_html_id + '">' + @helper_span_start
		r <<	'<input type="checkbox" style="width:auto;" ' + checked +
      ' onchange="return kopal.page.todo_status_change_event(\'' + @child_html_id +
			'\', \'' + status_link + '\');">'
		r << '<s>' if @hash[:child][:'status'] == 'done'
		r <<	in_place_editor(wikify(@hash[:child][:'text']), @child_html_id,
            Kopal.route.page_draw({:action => 'save_todo_element',
              :id => "#{@hash[:element][:id]}_#{@hash[:child_index]}",
              :page_id => @hash[:'page_id']})
					)
		r << '</s> &nbsp; done' if @hash[:child][:'status'] == 'done'
		r << @helper_span_close
		r << '</li>'
	end
	
	# This method returns a string wrapped in a "span" HTML element.
	# This returned HTML element contains a "Delete" link which is pointed to action -> delete_child_element
	# This method should be used to provide a "Delete" link to list, pair and todo page elements.
	#LATER: Take it to page_edit.js, all that it should be just is kopal.page.delete_child('E_2_5')
	def helper_link
		#RAILSBUG: Don't know why but even when I don't pass :escape => false here, It works correctly.
		delete_path = Kopal.route.page_draw(:action => 'delete_element_child',
      :page_id => @hash[:'page_id'], :element_id => @hash[:'element'][:id],
      :child_index => @hash[:child_index])
		r = "<span id=\"#{@child_helper_id}\" style=\"padding-left:10px;visibility:hidden;display:inline;\">"
		r << link_to_remote('Delete', 
			{
				:url => delete_path, 
				:before => "new Insertion.After('#{@child_helper_id}',
          '<span style=\"background-color:yellow;color:black\">Deleting Element....</span>')",
				:success => visual_effect(:highlight, @child_html_id, :duration => 2) + 
          visual_effect(:fade, @child_element_id),
				:confirm => "Are you sure you want to delete this element?"
			}, {:title => 'Delete this element'})
		r << '</span>'
		return r
	end

end
