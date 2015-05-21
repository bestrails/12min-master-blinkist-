class Admin::SuperusersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_superuser!

  private
  def ensure_superuser!
    unless current_user.superuser?
      sign_out

      redirect_to root_path

      return false
    end
  end
end
