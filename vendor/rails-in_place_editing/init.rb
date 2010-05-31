require File.dirname(__FILE__) + '/lib/in_place_editing'
require File.dirname(__FILE__) + '/lib/in_place_macros_helper'
ActionController::Base.send :include, InPlaceEditing
ActionController::Base.helper InPlaceMacrosHelper
