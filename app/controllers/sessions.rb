PadrinoApp::App.controllers :sessions do
  get :new do
    render "/sessions/new"
  end

  post :signup do

    form_params = params

    params[:last_update] = DateTime.now.utc
    params[:status] = 2
    params[:id] = SecureRandom.uuid
    params[:password] = params[:password_confirmation] = Nretnil::Password.generate(10)[:password]
    params[:role] = ""
    @account = Account.new(params)
    if @account.save
      flash.now[:success] = "Your Account has been saved.  You will recieve an email with credentials shortly." # user flash[:error] when redirecting
      flash[:success] = "Your Account has been saved.  You will recieve an email with credentials shortly." # user flash[:error] when redirecting
      
      begin
        email(  
              :from => "donotreply@nretnil.com", 
              :to => "mark@lintern.us", 
              :subject => "New User Request", 
              :content_type => :html,
              :body => render( "email/newuser", :layout => false, :locals => { 'user' => params } ) 
              )
      rescue => e
        logger.error(e)
        logger.error("Email did not send")
      end

      redirect url(:sessions, :new), 302
    else
      errors = ""
      @account.errors.each do |e|
        logger.error("Save Error: #{e}")
        errors += e[0] + " "
      end
      flash.now[:error] = errors
      flash[:error] = errors
      redirect url(:sessions, :new), 302, form_params
    end
  end

  post :create do
    if account = Account.authenticate(params[:username], params[:password])
      if account.status == 1
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
        flash[:error] = "Account is Disabled"
        logger.info("Account is Disabled")
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
