module Kopal::ApplicationHelper

  FILTER_AUTO_LOAD_PATH = Rails.root.join('app', 'views', '_kopal_filter')

  #Deprecate this method of auto-including from "_kopal_filter". Should depend only
  #Kopal::Theme::Filter called from controllers.
  def render_filters_for_home
    files = Dir[FILTER_AUTO_LOAD_PATH.to_s + '/_*.erb']
    files.each {|f|
     if f =~ /(before|after)_(body_(start|close)|page_(meta|header|front|sidebar|footer))/
      render :inline => "
        <% content_for(:#{$~}) do %>
        #{IO.read f}
        <% end %>
      "
     end
    }
    nil
  end
  
  def tk *args
    args << {} unless args.last.is_a? Hash
    args.last[:scope] ||= :kopal
    I18n.translate *args
  end
  
  #We need this wrapper because we can not make profile_comments_path(@kopal_profile) to match "/comment".
  #And if we can do say any day, deprecate this method.
  #@param, path in single_profile_instance
  def kp spi_path, *args
    if Kopal::Engine.spi?
      send(key, *args)
    else
      send("profile_#{key}", kopal_profile, *args)
    end
  end
end