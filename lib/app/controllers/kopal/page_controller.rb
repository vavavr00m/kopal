class Kopal::PageController < Kopal::ApplicationController

  def index
    page = params[:page][0]
    if page.blank?
      list_all
    else
      @page = Kopal::ProfilePage.find_by_page_name(page)
      if @page
        show_page
      else
        flash.now[:notice] = "Page #{page} does not exists."
        list_all
      end
    end
  end

  #Can't reach here by routing can we?
  def list_all
    render 'list_all'
  end

  def show_page
    @_page.title <<= @page.to_s
    render 'show_page'
  end
end