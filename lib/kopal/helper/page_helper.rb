module Kopal::Helper::PageHelper

  #redirects as expected.
  def redirect_2 url
    if request.xhr?
      render :update do |page|
        page.redirect_to url_for(url)
      end
    else
      redirect_to url
    end
  end

  def wikify string, markup = "html"
    string = "#{string}"
    #Convert
    # use following when it is supported by IE and Firefox
    #"<span style=\"white-space:pre-line;\">#{string}</span>"
    # from simple_format() in ActionView::Helpers::TextHelper
    string.gsub!(/\r\n?/, "\n")                     # \r\n and \r -> \n
    string.gsub!(/\n\n+/, "</p>\n\n<p>")            # 2+ newline  -> paragraph
    string.gsub!(/([^\n]\n)(?=[^\n])/, '\1<br />')  # 1 newline   -> br
		#TODO: change http://, www. and all to <a href....
		string = sanitize(string)
	end

  #pass an array of hashes as - {:label, :link, :weight, :title}, weight can be any digit.
  #options - {:max_font_size, :limit}
  def as_cloud ar, options = {} #ar => array
    max_font_size = options[:max_font_size] || 36
    min_font_size = 12
    limit = options[:limit]
    #named weight not mass, since its relative.
    biggest = 0
    ar.each { |a|
      biggest = a[:weight] if a[:weight] > biggest
    }
    if limit
      sorted_array = ar.sort { |x,y| y[:weight] <=> x[:weight]}
      sorted_array = sorted_array.slice(0...(limit.to_i))
      ar = ar & sorted_array #"sorted_array & a" will get them sorted.
    end
    r = ''
    ar.each { |a|
      #should decrease exponentially
      m = Math.sqrt(a[:weight])*max_font_size/Math.sqrt(biggest)
      m = m.to_int
      m = min_font_size if m < min_font_size
      m = max_font_size if m > max_font_size

      a[:'title'] = a[:label] if a[:'title'].blank?
      a[:label] = h(a[:label])

      r << link_to(a[:label], a[:link], :title => a[:title],
        :class => "cloud", :style => "font-size:#{m}px;")
      r << " "
    }
    return r
	end

  def gravatar_url email
    require 'md5'
    hash = MD5.md5 email
    return "http://www.gravatar.com/avatar/#{hash}.jpeg?s=120"
  end

  def whitespaced s, from = "_"
		return s.gsub(from, ' ')
	end

	def underscored s, from = " "
		return s.gsub(from, '_')
	end

  def format_date date, without_html = false
    return date unless date.is_a? Date or date.is_a? Time or date.is_a? DateTime

    m = ['Jan', 'Feb', 'March', 'April', 'May', 'June', 'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'] # Oh, we could have done this with strftime() method!
    w = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'] # sunday is 0 for both Time and Date

    current = Time.zone.now #Same as Time.now.utc
    if date.year < current.year
      r = "#{m[date.month-1]}, #{date.year}"
    elsif date.month < current.month or current.mday - date.mday > 1
      r = "#{w[date.wday]}, #{date.mday} #{m[date.month-1]}"
    elsif date.instance_of? Date
      r = "Yesterday"
    elsif current.mday - date.mday == 1
      r = date.strftime("Yesterday, %I:%M%p")
    elsif current.hour > date.hour or current.min - date.min > 20
      r = date.strftime("Today, %I:%M%p")
    elsif current.min - date.min > 2
      r = "Minutes before"
    elsif current.min >= date.min
      r = 'Seconds before'
    else
      r = date.to_s(:long) #date in future?
    end
    return  r if without_html
    return "<abbr title=\"#{date.to_s(:rfc822)}\">#{r}</abbr>"
  end
  alias d format_date

  #Wrapper around Script.aculo.us's In Place Editor.
  def in_place_editor element_text, id, url, options = {}
    id += "_InPlaceEditor"
    tag = "<span class=\"in_place_editor\" id=\"#{id}\">#{element_text}</span>"
    r = "new Ajax.InPlaceEditor(\"#{id}\", \"#{url}\""
    unless options.blank?
      new_options = {}
      options.each {|k,v|
        new_options[k.to_s.camelcase(:lower)] = array_or_string_for_javascript(v)
      }
      r << "," + options_for_javascript(new_options)
    end
    r << ")"
    tag + javascript_tag(r)
  end
end
