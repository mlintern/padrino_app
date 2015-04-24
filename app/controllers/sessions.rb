PadrinoApp::App.controllers :sessions do
  get :new do
    render "/sessions/new"
  end

  post :create do
    if account = Account.authenticate(params[:username], params[:password])
      unless account.status == 0
        token = SecureRandom.hex
        account.update({ :token => token, :last_login => Time.now.utc })
        if account
          if params[:remember_me]
            response.set_cookie( "user", :value => token, :path => '/' , :expires => (Time.now.utc + 24*60*60) )
          else
            response.set_cookie( "user", :value => token, :path => '/' , :expires => (Time.now.utc + 30*60) )
          end
        end
        redirect url(:base, :index)
      else
        flash[:error] = "User is Disabled"
        logger.info("User is Disabled")
        redirect url(:sessions, :new), 302
      end
    else
      flash[:error] = "Username or Password is wrong"
      logger.info("Username or Password is Wrong")
      redirect url(:sessions, :new), 302
    end
  end

  get :destroy do
    response.delete_cookie("user", :path => '/')
    session[:user] = nil
    session[:errors] = nil
    session[:redirect_to] = nil
    flash[:error] = nil
    flash[:success] = nil
    redirect url(:sessions, :new)
  end
end
