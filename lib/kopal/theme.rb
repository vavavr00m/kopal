#=== Themeing is only a concept and does NOT work for now. However filters do work. Check them at Kopal::Theme::Filter
#
#
#A Kopal theme is a set of views that are used to display actions of Kopal::HomeController (only).
#
#
#= Kopal::Theme for Designers
#== Theme structure
#
#A theme MUST contain following file(s).
#
#* ./theme.yml
#* ./layouts/theme.html.erb
#
#Optionally it may contain following additional file(s).
#
#* ./screenshot.png
#
#*NOTE*: Name of a theme is determined from the name of the root folder.
#
#TODO: Whenever <tt>params[:stylesheet] = 'print'</tt>, if selected theme doesn't has
#<tt>./static/print.css</tt> or <tt>./dynamic/print.css.erb</tt> (or in <tt>theme.yml</tt>,
#<tt>print_stylesheet</tt> is +false+ or +nil+), Kopal uses default print
#stylesheet and layout.
#
#== Inside <tt>theme.yml</tt>
#
#The <tt>./theme.yml</tt> file contains information about theme in YAML format and has following attributes.
#At present all attributes are optional.
#
#  ---
#   author: 
#     name: [Name of theme author/group.]
#     url: [URL of author/group.]
#   version: [Released version of theme.]
#   url: [URL for this theme if any.]
#
#
#
#A theme must include all these yielding regions -
#+page_meta+:: 
#   Should be yielded with in <tt><head></head></tt> tags. Will
#   write all necessary metadata.           
#+page_after_body_start+::
#   Right after the <tt><body></tt> tag.
#+page_header+::
#   Contains markup that are displayed at top of any page.
#+page_sidebar+::
#   Contains navigation and other markups that should be displayed in sidebar.
#   (TODO: not named page_left_sidebar, as designer may put it anywhere. Also,
#   later, designer should have complete freedom, like placing some part of
#   sidebar on left, some on right and some on top/bottom.)
#+page_footer+::
#   Markup to be included in a page's footer.
#+page_before_body_end+::
#   Markup that needs to be included before the closing <tt></body></tt> tag.
#   For example, Google Analytics code.
#
#Apart from this, a theme must also call an unnamed +yield+ to include the main markup section.
#
#== Default theme
#Kopal ships with a default theme stored in <tt>lib/app/views/default-theme/</tt>.
#This section gives information about the default theme.
#
#TODO: Should deprecate personalised <tt><div></tt> id names in favour of more generic names
#as Kopal is open-source and these names are going to be part of the api.
#Like +PageHeader+ instead of +SurfaceAbove+.
#
#For default kopal theme, main body is divided into four part.
# 1. SurfaceAbove 
# 2. SurfaceFront 
# 3. SurfaceLeft 
# 4. SurfaceDown 
#
#= Kopal::Theme for developers.
#
#== Theme filters.
#Kopal makes available many callbacks via filters on themes that can be used to include
#markup at various places in a layout.
#For more information on theme filters please see Kopal::Theme::Filter
#
class Kopal::Theme
  
  DEFAULT_THEME_PATH = Rails.root.join('vendor', 'themes', 'kopal') #"themes' and not Kopal's singularity standard 'theme', to match 'gems', 'plugins'.
  
  def prepend_theme_path *paths #Can pass multiple theme paths
    paths = paths[0] if paths[0].is_a? Array
    raise NotImplementedError
  end
end
