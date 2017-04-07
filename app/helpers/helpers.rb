#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

PadrinoApp::App.helpers do
  ####
  # Name: string_to_hash
  # Description: returns hash from a string that is a hash
  # Arguments: string - of hash
  # Response: hash
  ####
  def string_to_hash(s)
    JSON.parse(s.tr('\'', '"').gsub(/:([a-zA-z]+)/, '"\\1"').gsub('=>', ': ').gsub(' :  ', ': '))
  rescue JSON::ParserError => e
    logger.error 'Unable to Parse: ' + s
    logger.error e
    return false
  end

  ####
  # Name: attributes_to_remove
  # Description: returns list of attributes used in remove_elements
  # Arguments: None
  # Response: Array of symbols
  ####
  def attributes_to_remove
    %i[token crypted_password last_update]
  end

  ####
  # Name: allowed_attributes
  # Description: returns list of attributes used in remove_other_elements
  # Arguments: None
  # Response: Array of symbols
  ####
  def allowed_attributes
    %i[username name surname email role password password_confirmation]
  end

  ####
  # Name: default
  # Description: returns default of the defined property
  # Arguments: String - name of property
  # Response: string
  ####
  def default(property)
    defaults = { photo: '/images/default.png' }
    defaults[property.to_sym]
  end

  ####
  # Name: current_user
  # Description: Will return the currently logged in Account
  # Arguments: None
  # Response: Account object
  ####
  def current_user
    return @current_user ||= Account.first(token: request.cookies['user']) if request.cookies['user']
  end

  ####
  # Name: add_update_properties
  # Description: Updates AccountProperty Table or creates new entry for user params[:id]
  # Arguments: data - json object which may contain AccountProperty
  # Response: true or halt 400
  ####
  def add_update_properties(data)
    current_properties = ['photo']

    if data['properties']
      data['properties'].each do |p|
        next unless current_properties.include? p['name']
        property = AccountProperty.first(id: params[:id], name: p['name'])
        if property
          return true if property.update(value: p['value'])
          property.errors.each do |e|
            logger.error("Save Error: #{e}")
          end
          errors = []
          property.errors.each do |e|
            errors << e
          end
          halt 400, { success: false, errors: errors }.to_json
        else
          property = AccountProperty.new(id: params[:id], name: p['name'], value: p['value'])
          if property.save
          else
            property.errors.each do |e|
              logger.error("Save Error: #{e}")
            end
            errors = []
            property.errors.each do |e|
              errors << e
            end
            halt 400, { success: false, errors: errors }.to_json
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
  def user_property(id, property)
    AccountProperty.first(id: id, name: property) || AccountProperty.new(id: current_user.id, name: property, value: default('photo'))
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
      redirect url(:base, :index)
    end
  end

  ####
  # Name: login
  # Description: check if user is logged in
  # Arguments: None
  # Response: true or redirect to /sessions/new
  ####
  def login(redirect = true)
    return true unless current_user.nil?
    flash[:error] = 'Login is required.' if redirect
    redirect url(:sessions, :new), 302 if redirect
    false
  end

  ####
  # Name: auth_creds
  # Description: takes the encoded authorication string and returns a json object of the username and password
  # Arguments: auth_deader - string - Base64 encoded authentication
  # Response: json object - username and password
  ####
  def auth_creds(auth_header)
    return { username: nil, password: nil } unless auth_header
    plain = Base64.decode64(auth_header.gsub('Basic ', ''))
    username = plain.split(':')[0]
    password = plain.split(':')[1]
    { username: username, password: password }
  end

  ####
  # Name: api_auth
  # Description: checks user's authorization and permissions
  # Arguments: auth_header - string - Base64 encoded authentication
  #            role - optional - string - name of the required role
  # Response: current_user, authorized user or halt 403
  ####
  def api_auth(auth_header, role = nil)
    if current_user
      return current_user if role.nil?
      return current_user if current_user.role[role]
    else
      logger.debug creds = auth_creds(auth_header)
      account = Account.authenticate(creds[:username], creds[:password]) || Account.token_authenticate(creds[:username], creds[:password])
      return account if account && ((role.nil? || account.role[role]) && account.active?)
    end
    halt 403, { success: false, message: 'You are Unauthorized' }.to_json
  end

  ####
  # Name: permissions_check
  # Description: checks that the logged in user has specified permission
  # Arguments: role - string
  # Response: true, false or redirect_last
  ####
  def permission_check(role, redirect = true)
    login
    return true if !current_user['role'].nil? && current_user.role[role]
    if redirect
      flash[:error] = role + ' right required to view that page.'
      redirect_last
    end
    false
  end

  ####
  # Name: owner?
  # Description: checks to see if current user owns requested data
  # Arguments: owner_id - integer
  # Response: true or false
  ####
  def owner?(owner_id)
    current_user.id.to_s == owner_id
  end

  ####
  # Name: api_owner?
  # Description: checks to see if current user owns requested api data
  # Arguments: auth_header - string - Base64 encoded authentication
  #            owner_id - integer
  # Response: true or false
  ####
  def api_owner?(auth_header, owner_id)
    if current_user
      owner? current_user.id.to_s
    else
      creds = auth_creds(auth_header)
      if (account = Account.authenticate(creds[:username], creds[:password])) && !creds.nil?
        return true if account.id.to_s == owner_id
      end
    end
    false
  end

  ####
  # Name: remove_elements
  # Description: strips hash object of specified elements
  # Arguments: data - hash - object to be stipped
  #            elements - array of symbols
  # Response: hash
  ####
  def remove_elements(data, elements = attributes_to_remove)
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
  def remove_other_elements(data, elements = allowed_attributes)
    data.each do |x, _y|
      data.delete(x) unless elements.include? x.to_sym
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
    data.each do |a, b|
      result += a.to_s + '=' + b.to_s + '&'
    end
    result[0...-1].gsub('"', '\\"').gsub('[', '\\[').gsub(']', '\\]').gsub(', ', ',')
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
      data.to_s.valid_json? ? data : data.to_json
    end
  end

  ####
  # Name: create_data
  # Description: takes a hash object of name => type and returns fake data element
  # Arguments: data - hash - what data element should contain and look like
  #   example: {"name"=>"name", "surname"=>"surname", "id"=>"uuid", "dob"=>"date", "about"=>"sentence", "email"=>"email", "username"=>"username"}
  # Response: string - {"a":"b","c":"d"}
  ####
  def create_data(elements)
    hash = {}
    name = surname = number = username = nil
    elements.each do |a, b|
      case b
      when 'sentence'
        hash[a] = (Nretnil::FakeData.words((rand(15) + 15)) + '.').capitalize
      when 'uuid'
        hash[a] = Nretnil::Password.uuid
      when 'email'
        if username
          hash[a] = username + '@' + Nretnil::FakeData.word + '.com'
        elsif name && surname
          username = (hash['name'][0, 1] + hash['surname']).downcase
          hash[a] = username + '@' + Nretnil::FakeData.word + '.com'
        elsif name
          hash[a] = name + '@' + Nretnil::FakeData.word + '.com'
        else
          word ||= Nretnil::FakeData.word
          number ||= Nretnil::FakeData.number(3).to_s
          username ||= word + number
          hash[a] = username + '@' + Nretnil::FakeData.word + '.com'
        end
      when 'name'
        hash[a] = name ||= Nretnil::FakeData.name
      when 'surname'
        hash[a] = surname ||= Nretnil::FakeData.surname
      when 'fullname'
        name ||= Nretnil::FakeData.surname
        surname ||= Nretnil::FakeData.surname
        hash[a] = name + ' ' + surname
      when 'username'
        if username
          hash[a] = username
        elsif name && surname
          username ||= (name[0, 1] + surname).downcase
          hash[a] = username
        elsif name
          number ||= Nretnil::FakeData.number(3).to_s
          username = name + number
          hash[a] = name + number
        else
          number ||= Nretnil::FakeData.number(3).to_s
          word ||= Nretnil::FakeData.word
          username = word + number
          hash[a] = username
        end
      when 'date'
        hash[a] = Nretnil::FakeData.date
      when 'number'
        hash[a] = Nretnil::FakeData.number
      else
        hash[a] = b
      end
    end
    hash
  end

  ####
  # Name: trasnlate_title
  # Description: takes a title and lanugage and returns new title
  # Arguments: title - string
  #            language - string
  # Response: string
  ####
  def translate_title(title, language)
    title_words = title.split(' ')
    new_title = title
    title_words.each do |w|
      new_title = new_title.gsub(w, w.scramble)
    end

    '[' + language + '] ' + new_title
  end

  ####
  # Name: trasnlate_body
  # Description: takes a body text (html) and language and returns a translated text
  # Arguments: body - string
  #            _language - string
  # Response: string
  ####
  def translate_body(body, _language)
    word_array = body.gsub(%r{<\/?[^>]+>}, '').gsub(/[!@#`$%^&*()-=_+|;:",.<>?]/, '').gsub('\'s', '').split(' ').uniq
    new_html = body
    word_array.each do |word|
      new_word = word.scramble
      new_html = new_html.gsub(' ' + word + ' ', ' ' + new_word + ' ')
      new_html = new_html.gsub(word + ' ', new_word + ' ')
      new_html = new_html.gsub(' ' + word, ' ' + new_word)
    end

    new_html
  end

  ####
  # Name: params_to_url
  # Description: takes hash of params and turns it into url params
  # Arguments: params - hash
  #            ignore - Array - items not to include
  # Response: string
  ####
  def params_to_url(params, ignore = [])
    elements = []
    params.each do |a, b|
      elements << "#{a}=#{b}" unless ignore.include? a
    end
    param_url = '?' + elements.join('&')
    param_url
  end

  ####
  # Name: signmal_ocm(project)
  # Description: tell ocm that a project status has changed
  # Arguments: project - project that needs notified
  # Response: boolean
  ####
  def signal_ocm(project, domain = 'https://dev.cpdm.oraclecorp.com')
    logger.info project.inspect
    account = Account.first(id: project.user_id)
    ocmapp = OCMApp.first(user_id: account.id)
    url = domain + '/api/translation_projects/' + ocmapp.app_install_id + '/projects/' + project.id
    return get_callback_auth(url, ocmapp.username, ocmapp.api_key)
  rescue StandardError => e
    logger.error e
    return false
  end

  ####
  # Name: get_callback_auth
  # Description: make a get request to compendium
  # Arguments: url - location of callback
  # Response: boolean
  ####
  def get_callback_auth(url, username, api_key)
    auth = { username: username, password: api_key }
    logger.info HTTParty.get(URI.unescape(url), basic_auth: auth, verify: false, headers: { 'Content-Type' => 'application/x-json' })
    return true
  rescue StandardError => e
    logger.error e
    logger.error e.backtrace
    return false
  end

  ####
  # Name: post_callback
  # Description: post back to compendium without authentication
  # Arguments: url - location of callback
  #            data - json object of data
  # Response: boolean
  ####
  def post_callback(url, data = {})
    logger.info HTTParty.post(URI.unescape(url), body: data, verify: false, headers: { 'Content-Type' => 'application/x-json' })
    return true
  rescue StandardError => e
    logger.error e
    logger.error e.backtrace
    return false
  end

  ####
  # Name: post_callback_auth
  # Description: post back to compendium with authentication
  # Arguments: url - location of callback
  #            data - json object of data
  #            username - compendium username
  #            api_key - compendium user's api_key
  # Response: boolean
  ####
  def post_callback_auth(url, data, username, api_key)
    auth = { username: username, password: api_key }
    logger.info response = HTTParty.post(URI.unescape(url), body: data.to_json, basic_auth: auth, verify: false, headers: { 'Content-Type' => 'application/x-json' })
    return false if response.key? 'error'
    return true
  rescue StandardError => e
    logger.error e
    logger.error e.backtrace
    return false
  end

  ####
  # Name: delete_project(project,user)
  # Description: delete a project and all its components
  # Arguments: project - project
  #            user - user trying to delete project
  # Response: boolean
  ####
  def delete_project(project, user)
    return 403, { success: false, info: 'You do not have permission to perform this action.' }.to_json if project.user_id != user.id
    assets = Asset.all(project_id: params[:id])
    assets.each do |asset|
      next if asset.destroy
      errors = []
      asset.errors.each do |e|
        errors << e
      end
      return 400, { success: false, info: errors }.to_json
    end
    languages = Language.all(project_id: params[:id])
    languages.each do |lang|
      next if lang.destroy
      errors = []
      asset.errors.each do |e|
        errors << e
      end
      return 400, { success: false, info: errors }.to_json
    end

    return 200, { success: true, info: "Project was successfully deleted. Along with it's assets and languages." }.to_json if project.destroy
    errors = []
    project.errors.each do |e|
      errors << e
    end
    return 400, { success: false, info: errors }.to_json
  rescue StandardError => e
    logger.error e
    logger.error e.backtrace
    return false
  end

  ####
  # Name: ocm_create_post(data,ocmapp)
  # Description: send translated content to OCM/Compendium
  # Arguments: data - json object of new content data
  #            ocmapp - ocmapp object
  #            domain - optional - tell which environment to send to. defaults to dev
  # Response: boolean
  ####
  def ocm_create_post(data, ocmapp, domain = 'https://dev.cpdm.oraclecorp.com')
    auth = { username: ocmapp.username, password: ocmapp.api_key }
    post = { post_attributes: { title: data[:title], body: data[:body] }, remote_project_id: data[:project_id], source_post_id: data[:source_id], language_code: data[:language] }
    url = '/api/translation_projects/' + ocmapp.app_install_id + '/create_translation'
    response = HTTParty.post(domain + url, body: post.to_json, basic_auth: auth, verify: false, headers: { 'Content-Type' => 'application/x-json' })
    return true if response.code == 200
    return response.parsed_response
  rescue StandardError => e
    logger.error e
    logger.error e.backtrace
    return false
  end
end
