class UsersController < ApplicationController
  
  before_filter :authenticate_user!
  
  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    # TODO: test this logic
    params[:user].delete(:password) if params[:user][:password].blank?
    params[:user].delete(:password_confirmation) if params[:user][:password_confirmation].blank?

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to entries_url, :notice => 'User was successfully updated.' }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
  

end
