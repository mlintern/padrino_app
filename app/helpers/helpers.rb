PadrinoApp::App.helpers do

  # Redirect to last page or root
  def redirect_last
    if session[:redirect_to]
      redirect_url = session[:redirect_to]
      session[:redirect_to] = nil
      redirect redirect_url
    else
      redirect "/"
    end  
  end

  # Require login to view page

  def user_permission_required
    if session[:user]
      return true
    else
      flash[:info] = "Login is required."
      session[:redirect_to] = request.fullpath
      redirect "/sessions/new"
      return false
    end
  end

  alias :user :user_permission_required

  # Require admin role to view page
  def admin_permission_required
    log("Admin Permission Check")
    log("admin? = ",admin?)
    if current_user && admin?
      session[:redirect_to] = request.fullpath
      return true
    else
      flash[:error] = "Admin rights required to view that page."
      redirect_last
      return false
    end
  end

  alias :admin :admin_permission_required

  # Check user has admin role
  def admin?
    puts current_user.inspect
    return current_user.role == 'admin'
  end

  alias :is_admin? :admin?

  # Check logged in user is the owner
  def owner? owner_id
    if current_user && current_user.id.to_i == owner_id.to_i
      return true
    else
      flash[:error] = "You are not authorised to view that page."
      redirect "/"
      return false
    end
  end

  alias :is_owner? :owner?

  # Return current_user record if logged in
  def current_user
    return @current_user ||= Account.first(:token => request.cookies["user"]) if request.cookies["user"]
    @current_user ||= Account.first(:token => session[:user]) if session[:user]
  end

  # check if user is logged in?
  def logged_in?
    !!session[:user]
  end

  def log(text,value = nil)
    logger.info(" - - - #{text}#{value} - - - ")
  end

end