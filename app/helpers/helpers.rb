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
  def login
    if current_user
      return true
    else
      flash[:error] = "Login is required."
      redirect url(:sessions, :new), 302
      return false
    end
  end

  def auth_creds(auth_header)
    plain = Base64.decode64(auth_header.gsub("Basic ",""))
    username = plain.split(':')[0]
    password = plain.split(':')[1]
    return { :username => username, :password => password }
  end

  def api_auth(auth_header, role = nil )
    if current_user
      if role.nil?
        puts current_user.status
        return current_user
      else
        if current_user.role[role]
          return current_user
        else
          halt 403, { :success => false, :message => "You are Unauthorized" }.to_json
        end
      end
    else
      unless auth_header.nil?
        creds = auth_creds(auth_header)
        if account = Account.authenticate(creds[:username],creds[:password])
          if ( role.nil? || account.role[role] ) && account.status != 0
            return account
          else
            halt 403, { :success => false, :message => "You are Unauthorized" }.to_json
          end
        else
          halt 403, { :success => false, :message => "You are Unauthorized" }.to_json
        end
      else
        halt 403, { :success => false, :message => "You are Unauthorized" }.to_json
      end
    end
  end

  # Require admin role to view page
  def admin_permission_required
    login

    # log("Admin Permission Check")
    # log("admin? = ",admin?)
    if admin?
      session[:redirect_to] = request.fullpath
      return true
    else
      flash[:error] = "Admin right required to view that page."
      redirect_last
      return false
    end
  end

  alias :admin :admin_permission_required

  # Require user role to view page
  def user_permission_required
    login

    # log("User Permission Check")
    # log("user? = ",user?)
    if user?
      session[:redirect_to] = request.fullpath
      return true
    else
      flash[:error] = "User right required to view that page."
      redirect_last
      return false
    end
  end

  alias :user :user_permission_required

  # Require user role to view page
  def compendium_permission_required
    login

    # log("User Permission Check")
    # log("user? = ",user?)
    if compendium?
      session[:redirect_to] = request.fullpath
      return true
    else
      flash[:error] = "Comepndium right required to view that page."
      redirect_last
      return false
    end
  end

  alias :compendium :compendium_permission_required

  # Check user has user role
  def user?
    if current_user['role'].nil?
      return false
    else
      return current_user.role['user']
    end
  end

  # Check user has admin role
  def admin?
    if current_user['role'].nil?
      return false
    else
      return current_user.role['admin']
    end
  end

  alias :is_admin? :admin?

  # Check user has other role
  def other?
    if current_user['role'].nil?
      return false
    else
      return current_user.role['other']
    end
  end

  # Check user has other role
  def compendium?
    if current_user['role'].nil?
      return false
    else
      return current_user.role['compendium']
    end
  end

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
  end

  # check if user is logged in?
  def logged_in?
    !!session[:user]
  end

  def log(text,value = nil)
    logger.info(" - - - #{text}#{value} - - - ")
  end

  def norm_data(data)
    result = '?'
    data.each do |a,b|
      result += a.to_s+'='+b.to_s+'&'
    end
    result[0...-1]
  end

  def json_data(data)
    if data == {}
      '{}'
    else
      data.to_s.is_json? ? data : data.to_json
    end
  end

end
