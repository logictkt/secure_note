class UsersController < ApplicationController
  def index
    @users = User.order(:created_at)

    respond_to do |format|
      format.html
      format.md
    end
  end

  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html
      format.md
    end
  end
end
