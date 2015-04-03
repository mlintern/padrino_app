PadrinoApp::App.helpers do

  ####
  # Name: attributes_to_remove
  # Description: returns list of attributes used in remove_elements
  # Arguments: None
  # Response: Array of symbols
  ####
  def attributes_to_remove
    [:token,:crypted_password,:last_update]
  end

  ####
  # Name: allowed_attributes
  # Description: returns list of attributes used in remove_other_elements
  # Arguments: None
  # Response: Array of symbols
  ####
  def allowed_attributes
    [:username,:name,:surname,:email,:role,:password,:password_confirmation]
  end

  ####
  # Name: default
  # Description: returns default of the defined property
  # Arguments: String - name of property
  # Response: string
  ####
  def default(property)
    defaults = { :photo => '/images/default.png' }
    defaults[property.to_sym]
  end

  ####
  # Name: current_user
  # Description: Will return the currently logged in Account
  # Arguments: None
  # Response: Account object
  ####
  def current_user
    return @current_user ||= Account.first(:token => request.cookies["user"]) if request.cookies["user"]
  end

  ####
  # Name: add_update_properties
  # Description: Updates AccountProperty Table or creates new entry for user params[:id]
  # Arguments: data - json object which may contain AccountProperty
  # Response: true or halt 400
  ####
  def add_update_properties(data)
    current_properties = ["photo"]
    
    if data['properties']
      data['properties'].each do |p|
        if current_properties.include? p['name']
          property = AccountProperty.first(:id => params[:id], :name => p['name'])
          if property
            if property.update(:value => p['value'])
              return true
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

  ####
  # Name: user_property
  # Description: Returns AccountProperty for logged in User
  # Arguments: id - integer - id of user property
  #            property - string - name of property to be returned for the current_user   
  # Response: AccountProperty object
  ####
  def user_property(id,property)
    return AccountProperty.first(:id => id, :name => property) || AccountProperty.new({ :id => current_user.id, :name => property, :value => default("photo") })
  end

  ####
  # Name: redirect_last
  # Description: Will redirect to session[:redirect_to] or /
  # Arguments: None
  # Response: None
  ####
  def redirect_last
    if session[:redirect_to]
      redirect_url = session[:redirect_to]
      session[:redirect_to] = nil
      redirect redirect_url
    else
      redirect "/"
    end  
  end

  ####
  # Name: login
  # Description: check if user is logged in
  # Arguments: None
  # Response: true or redirect to /sessions/new
  ####
  def login
    if current_user
      return true
    else
      flash[:error] = "Login is required."
      redirect url(:sessions, :new), 302
    end
  end

  ####
  # Name: auth_creds
  # Description: takes the encoded authorication string and returns a json object of the username and password
  # Arguments: auth_deader - string - Base64 encoded authentication 
  # Response: json object - username and password
  ####
  def auth_creds(auth_header)
    if auth_header
      plain = Base64.decode64(auth_header.gsub("Basic ",""))
      username = plain.split(':')[0]
      password = plain.split(':')[1]
      return { :username => username, :password => password }
    else
      return { :username => nil, :password => nil }
    end
  end

  ####
  # Name: api_auth
  # Description: checks user's authorization and permissions
  # Arguments: auth_header - string - Base64 encoded authentication 
  #            role - optional - string - name of the required role
  # Response: current_user, authorized user or halt 403
  ####
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

  ####
  # Name: permissions_check
  # Description: checks that the logged in user has specified permission
  # Arguments: role - string
  # Response: true, false or redirect_last
  ####
  def permission_check(role, redirect = true)
    login
    if current_user['role'].nil?
      if redirect
        flash[:error] = role+" right required to view that page."
        redirect_last
      end
      return false
    else
      if current_user.role[role]
        return true
      else
        if redirect
          flash[:error] = role+" right required to view that page."
          redirect_last
        end
        return false
      end
    end
  end

  ####
  # Name: owner?
  # Description: checks to see if current user owns requested data
  # Arguments: owner_id - integer
  # Response: true or false
  ####
  def owner?(owner_id)
    return current_user.id.to_i == owner_id.to_i
  end

  ####
  # Name: api_owner?
  # Description: checks to see if current user owns requested api data
  # Arguments: auth_header - string - Base64 encoded authentication 
  #            owner_id - integer
  # Response: true or false
  ####
  def api_owner?(auth_header,owner_id)
    if current_user
      owner? current_user.id
    else
      creds = auth_creds(auth_header)
      if ( account = Account.authenticate(creds[:username],creds[:password]) ) && !creds.nil?
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

  ####
  # Name: remove_elements
  # Description: strips hash object of specified elements
  # Arguments: data - hash - object to be stipped
  #            elements - array of symbols
  # Response: hash
  ####
  def remove_elements(data,elements = attributes_to_remove)
    elements.each do |e|
      data.delete(e)
    end
    data
  end

  ####
  # Name: remove_other_elements
  # Description: strips hash object leaving only specified elements
  # Arguments: data - hash - object to be stipped
  #            elements - array of symbols
  # Response: hash
  ####
  def remove_other_elements(data,elements = allowed_attributes)
    data.each do |x,y|
      unless elements.include? x.to_sym
        data.delete(x)
      end
    end
    data
  end

  ####
  # Name: norm_data
  # Description: takes a hash object and turns it into a string of arguments
  # Arguments: data - hash - object to be transformed
  # Response: string - ?x=b&c=d
  ####
  def norm_data(data)
    result = '?'
    data.each do |a,b|
      result += a.to_s+'='+b.to_s+'&'
    end
    result[0...-1].gsub('"','\\"').gsub("[","\\[").gsub("]","\\]").gsub(", ",",")
  end

  ####
  # Name: json_data
  # Description: takes a hash object and turns it into a string json object
  # Arguments: data - hash - object to be transformed
  # Response: string - {"a":"b","c":"d"}
  ####
  def json_data(data)
    if data == {}
      '{}'
    else
      data.to_s.is_json? ? data : data.to_json
    end
  end

end
