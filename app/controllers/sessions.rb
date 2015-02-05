PadrinoApp::App.controllers :sessions do
  get :new do
    render "/sessions/new"
  end

  post :create do
    if account = Account.authenticate(params[:username], params[:password])
      response.set_cookie( "user", :value => account.token, :path => '/' , :expires => (Time.now + 52*7*24*60*60) )  if params[:remember_me]
      redirect url(:base, :index)
    else
      flash[:error] = "Username or Password is wrong"
      log("Username or Password is Wrong")
      redirect url(:sessions, :new), 302
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
