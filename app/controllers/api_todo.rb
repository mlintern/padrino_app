require "securerandom"

PadrinoApp::App.controllers :todos, :map => '/api/todos' do

  before do
    headers "Content-Type" => "application/json; charset=utf8"
    @api_account = api_auth(request.env["HTTP_AUTHORIZATION"], "user")
  end

  ####
  # Endpoint: GET /api/todos
  # Description: get todo list
  # Authorization: user
  # Arguments: None
  # Response: json object
  ####
  get :index do
    todos = Todo.all(:user_id => @api_account.id)
    return 200, todos.to_json
  end

  ####
  # Endpoint: POST /api/todos
  # Description: create todo item
  # Authorization: user
  # Arguments: json object
  #   required: title
  # Response: json object
  ####
  post :index do

    data = JSON.parse request.body.read
    if (data["title"])
      data = remove_other_elements(data,[:title])
      data["user_id"] = @api_account.id
      data["id"] = SecureRandom.uuid
      todo = Todo.new(data)
      if todo.save
        return 200, todo.to_json
      else
        errors = []
        todo.errors.each do |e|
          errors << e
        end
        return 400, { :success => false, :errors => errors }.to_json
      end
    else
      return 400, { :success => false, :error => "Payload must contain title." }.to_json
    end

  end

  ####
  # Endpoint: PUT /api/todos/:id
  # Description: get todo list
  # Authorization: user
  # Arguments: json object of elements to update
  #  options: title, completed (boolean)
  # Response: json object
  ####
  put :todo, :map => '/api/todos/:id' do

    data = JSON.parse request.body.read

    if (data["title"] || data["completed"])
      data = remove_other_elements(data,[:title,:completed])
      todo = Todo.get(params[:id])
      if todo
        if @api_account.id == todo.user_id
          if todo.update(data)
            return 200, todo.to_json
          else
            errors = []
            todo.errors.each do |e|
              errors << e
            end
            return 400, { :success => false, :errors => errors }.to_json
          end
        else
          return 403, { :success => false, :errors => "Forbidden" }.to_json
        end
      else
        return 400, { :success => false, :errors => "Bad todo id." }.to_json
      end
    else
      return 400, { :success => false, :error => "Payload must contain title or completed." }.to_json
    end
  end

  ####
  # Endpoint: DELETE /api/todos/:id
  # Description: Delete todo item
  # Authorization: user
  # Arguments: None
  # Response: json object
  ####
  delete :todo, :map => '/api/todos/:id' do
    todo = Todo.get(params[:id])
    if todo
      if @api_account.id == todo.user_id
        if todo.destroy
          return 200, { :success => true, :content => "Todo was deleted." }.to_json
        else
          errors = []
          todo.errors.each do |e|
            errors << e
          end
          return 400, { :success => false, :errors => errors }.to_json
        end
      else
        return 403, { :success => false, :errors => "Forbidden" }.to_json
      end
    else
      return 400, { :success => false, :errors => "Bad todo id." }.to_json
    end
  end

  after do
    @api_account = nil
  end

end
