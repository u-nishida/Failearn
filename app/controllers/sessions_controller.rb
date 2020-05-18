class SessionsController < ApplicationController

  def new
  end

  def create
    auth = request.env['omniauth.auth']
    if auth.present?
      user = User.find_or_create_from_auth(request.env['omniauth.auth'])
      session[:user_id] = user.id
      redirect_to user
    else
      user = User.find_by(email: params[:session][:email].downcase)
    end

    if user &&  user.authenticate(params[:session][:password])
      log_in(user)
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      flash[:success] = 'ログインに成功しました'
      redirect_to user
    else
      flash[:danger] = 'ログインに失敗しました'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in? #二重ログアウトによるエラーを防止
    flash[:info] = 'ログアウトしました'
    redirect_to login_path
  end

  def failure
    redirect_to root_url
  end

end
