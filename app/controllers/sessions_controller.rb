class SessionsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: :create

  def new
  end

  def create
    session[:steam_info]= {}
    session[:steam_info][:uid] = request.env['omniauth.auth'][:uid]
    session[:steam_info][:info] = request.env['omniauth.auth'][:info]

    user = User.find_or_create_by(steam_id: session[:steam_info][:uid])
    login user
    redirect_back_or root_url
  end

  def failure
    redirect_to root_url, :alert => "Authentication error: #{params[:message].humanize}"
  end

  def destroy
    logout 
    redirect_to root_url
  end
end
