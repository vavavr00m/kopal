#
#There are a total of 12 filters available.
#0.  before_page_meta
#0.  after_page_meta
#0.  after_body_start
#0.  before_page_header
#0.  after_page_header
#0.  before_page_front
#0.  after_page_front
#0.  before_page_sidebar
#0.  after_page_sidebar
#0.  before_page_footer
#0.  after_page_footer
#0.  before_body_close
#
#To include a filter in Kopal layout, define them in <tt>RAILS_ROOT/app/views/_kopal_filter</tt>.
#For example to include something in <tt>after_body_start</tt> region, write it in
#<tt>RAILS_ROOT/app/views/_kopal_filter/_after_body_start.html.erb</tt>.
#
#=== Anything written from here on is only concept and does NOT work.
#
#TODO: Theme filters should also be available at per user level along with site-wide filters. Such
#  filters content can be saved in database.
#
#All methods accept
#
#string::  Determined as the text to be displayed.
#array::   Name of templates/files/partials whose content will be rendered to string.
#hash::    same argument as to +render+, like <tt>:text => ''</tt> or <tt>:partial => </tt>.
#symbol::  Name of the method which returns an <tt>array/string/hash</tt> in above format.
#proc::    Returns same as +symbol+.
#
#*NOTE* Any method can be called multiple times and it will chain the filters.
#
#*TODO* Some includes like Google Analytics, shouldn't only be included in HomeController, but may
#also be in OrganiseController. By default filters should work only in HomeController but can be made universal.
#
#Filter rigth name?
#Also Theme::Filter is right? Kopal::LayoutFilter instead?
module Kopal::Theme::Filter

  #If application uses a lot of filters, this method can be used to define
  #all the filters in one call.
  #
  #It takes only one argument which must be name of the filter method as a +symbol+. That method
  #must return a hash in following form -
  #
  #  :before_page_meta => object_for_kopal_layout_after_page_meta,
  #  :after_page_meta => object_for_kopal_layout_before_page_meta,
  #  ....,
  #  ....,
  #
  #--
  #<tt>:kopal_layout_before_page_meta</tt> is also accepted?
  #++
  #
  def kopal_layout_filter sym
    
  end

  #Displayed before default meta elements.
  def kopal_layout_before_page_meta

  end

  #Displayed after the default meta included by Kopal. For example
  #stylesheets and javascript libraries.
  def kopal_layout_after_page_meta

  end

  #Displayed right after <tt><body></tt> tag.
  def kopal_layout_after_body_start

  end

  #Displayed right before ending <tt></body></tt> tag.
  def kopal_layout_before_body_close

  end

  #Displayed before the header of the page within \#SurfaceAbove in default theme.
  def kopal_layout_before_page_header

  end

  #Displayed after the header of the page within \#SurfaceAbove in default theme,.
  def kopal_layout_after_page_header

  end

  #Displayed within \#SurfaceFront block before yielding main region.
  def kopal_layout_before_page_front

  end

  #Displayed within \#SurfaceFront block after yielding main region.
  def kopal_layout_after_page_front

  end

  #Displayed before sidebar within \#SurfaceLeft of default theme.
  def kopal_layout_before_page_sidebar

  end

  #Displayed after yielding sidebar within \#SurfaceLeft of default theme.
  def kopal_layout_after_page_sidebar

  end

  #Displayed before page footer within \#SurfaceDown of default theme.
  def kopal_layout_before_page_footer

  end

  #Displayed after page footer within \#SurfaceDown of default theme.
  def kopal_layout_after_page_footer
    
  end
  
end