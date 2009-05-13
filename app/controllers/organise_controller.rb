class OrganiseController < ApplicationController
  before_filter :authorise

  def index
    redirect_to :dashboard
  end

  def dashboard
    redirect_to :edit_profile #for now
  end
end
