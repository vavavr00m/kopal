class Kopal::ProfileCommentsController < Kopal::ApplicationController
  
  def index
    @_page.title <<= "Shoutbox"
    @profile_comment = kopal_profile.comments.build params[:profile_comment]
    #Must be after the previous line and should pass argument "true" to work. Mongoid 2.0.2
    @profile_comments = kopal_profile.comments(true)
  end
  
  def create
    @profile_comment = kopal_profile.comments.build params[:profile_comment]
    #Must be after the previous line and should pass argument "true" to work. Mongoid 2.0.2
    @profile_comments = kopal_profile.comments(true)
    if @signed_user
      @profile_comment.user = @signed_user.user
    end
    if @profile_comment.save
      flash[:highlight] = "Comment submitted successfully"
      redirect_to kp(:profile_comments_path)
    else
      render :index, :status => 422
    end
  end
  
end