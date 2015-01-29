PadrinoApp::App.controllers :sessions do
  get :new do
    render "/sessions/new"
  end

  post :create do
    if account = Account.authenticate(params[:username], params[:password])
      set_current_account(account)
      response.set_cookie( "user", :value => account.token, :path => '/' , :expires => (Time.now + 52*7*24*60*60) )  if params[:remember_me]
      session[:user] = account.token
      redirect url(:base, :index)
    else
      flash.now[:error] = "Username or Password is wrong"
      render '/sessions/new', nil
    end
  end

  get :destroy do
    set_current_account(nil)
    response.delete_cookie("user", :path => '/')
    session[:user] = nil
    session[:errors] = nil
    redirect url(:sessions, :new)
  end
end
