PadrinoApp::App.helpers do

  def add_update_properties(data)
    current_properties = ["photo"]
    
    if data['properties']
      data['properties'].each do |p|
        if current_properties.include? p['name']
          property = AccountProperty.first(:id => params[:id], :name => p['name'])
          if property
            if property.update(:value => p['value'])
            else
              property.errors.each do |e|
                logger.error("Save Error: #{e}")
              end
              errors = []
              property.errors.each do |e|
                errors << e
              end
              halt 400, { :success => false, :errors => errors }.to_json
            end
          else
            property = AccountProperty.new(:id => params[:id], :name => p['name'], :value => p['value'])
            if property.save
            else
              property.errors.each do |e|
                logger.error("Save Error: #{e}")
              end
              errors = []
              property.errors.each do |e|
                errors << e
              end
              halt 400, { :success => false, :errors => errors }.to_json
            end
          end
        end
      end
    end
  end

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
          if ( role.nil? || account.role[role] ) && account.active?
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

  def permission_check(role)
    login
    if current_user['role'].nil?
      flash[:error] = role+" right required to view that page."
      redirect_last
      return false
    else
      if current_user.role[role]
        return true
      else
        flash[:error] = role+" right required to view that page."
        redirect_last
        return false
      end
    end
  end

  # Check logged in user is the owner
  def owner? owner_id
    if current_user && current_user.id.to_i == owner_id.to_i
      return true
    else
      flash[:error] = "You are not authorized to view that page."
      redirect "/"
      return false
    end
  end

  alias :is_owner? :owner?

  def api_owner?(auth_header,owner_id)
    if current_user
      if current_user.id.to_i == owner_id.to_i
        return true
      else
        return false
      end
    else
      creds = auth_creds(auth_header)
      if account = Account.authenticate(creds[:username],creds[:password])
        if account.id.to_i == owner_id.to_i
          return true
        else
          return false
        end
      else
        return false
      end
    end
  end

    def remove_elements(data,elements = [])
    elements.each do |e|
      data.delete(e)
    end
    data
  end

  def remove_other_elements(data,elements = [])
    data.each do |x,y|
      unless elements.include? x.to_sym
        data.delete(x)
      end
    end
    data
  end

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

  # Used to create API call on curl tool results page
  def norm_data(data)
    result = '?'
    data.each do |a,b|
      result += a.to_s+'='+b.to_s+'&'
    end
    result[0...-1].gsub('"','\\"').gsub("[","\\[").gsub("]","\\]").gsub(", ",",")
  end

  def json_data(data)
    if data == {}
      '{}'
    else
      data.to_s.is_json? ? data : data.to_json
    end
  end

end
