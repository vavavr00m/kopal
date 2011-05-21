class Kopal::SignController < Kopal::ApplicationController
  
  def in
    session[:kopal][:return_after_signin] = params[:and_return_to] ||
      session[:kopal][:return_after_signin] || kopal_root_path
  end
  
  def in_for_visiting_user
  end
  
  def in_for_profile_user
    params[:person]  = 'profile_user'
    @user = Kopal::User.authenticate :email => params[:email], :password => params[:password]
    if @user
      session[:kopal][:signed_user_id] = @user.id
      redirect_to kopal_root_path 
      return
    else
      flash[:notice] = "Wrong email or password"
    end
    render :in
  end
  
  def out
  end
end