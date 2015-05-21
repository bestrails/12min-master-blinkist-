class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :user, only: [:show, :edit, :update]

  def show
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      sign_in(current_user, :bypass => true) if user_params.include?(:password)
      flash[:notice] = t('users.update.success')
    else
      flash[:error] = t('users.update.failure')
    end

    render :show
  end

  def destroy
    @user = user
    if @user.destroy
      flash[:notice] = t('users.destroy.success')
    else
      flash[:error] = t('users.destroy.failure')
    end
  end

  def set_session_close_info
    session[:close_info] = true
    render nothing: true
  end

  private
  def user
    @user = current_user
  end

  def user_params
    params.required(:user).permit(:password, :password_confirmation, :kindle)
  end
end
