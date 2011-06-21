class Kopal::ProfileCommentsController < Kopal::ApplicationController
  
  def index
    @_page.title <<= "Shoutbox"
    @profile_comments = kopal_profile.comments
  end
  
  def create
    @profile_comments = kopal_profile.comments
    @profile_comment = kopal_profile.comments.build params[:profile_comment]
    if @signed_user
      @profile_comment.user = @signed_user.user
    end
    if @profile_comment.save
      flash[:highlight] = "Comment submitted successfully"
      redirect_to kopal_comments_path
    else
      render :index, :status => 422
    end
  end
  
end