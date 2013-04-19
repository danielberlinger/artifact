class ApplicationController < ActionController::Base

  protect_from_forgery

  private

  def require_authenticated_user_or_access_token!
    if Entry.authorize_by_token(params[:id], params[:token])
      ;
    else
      authenticate_user!
    end
  end

end
