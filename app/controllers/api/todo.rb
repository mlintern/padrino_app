#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

PadrinoApp::App.controllers :api_todos, map: '/api/todos' do
  before do
    headers 'Content-Type' => 'application/json; charset=utf8'
    @api_account = api_auth(request.env['HTTP_AUTHORIZATION'], 'user')
  end

  ####
  # Endpoint: GET /api/todos
  # Description: get todo list
  # Authorization: user
  # Arguments: None
  # Response: json object
  ####
  get :index do
    todos = Todo.all(user_id: @api_account.id, order: [:title.asc])
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
    return 400, { success: false, error: 'Payload must contain title.' }.to_json unless data['title']

    data = remove_other_elements(data, [:title])
    data['user_id'] = @api_account.id
    data['id'] = SecureRandom.uuid
    todo = Todo.new(data)
    return 200, todo.to_json if todo.save

    errors = []
    todo.errors.each do |e|
      errors << e
    end
    return 400, { success: false, errors: errors }.to_json
  end

  ####
  # Endpoint: PUT /api/todos/:id
  # Description: get todo list
  # Authorization: user
  # Arguments: json object of elements to update
  #  options: title, completed (boolean)
  # Response: json object
  ####
  put :todo, map: '/api/todos/:id' do
    data = JSON.parse request.body.read

    return 400, { success: false, error: 'Payload must contain title or completed.' }.to_json unless data.key?('title') || data.key?('completed')

    data = remove_other_elements(data, %i[title completed])
    todo = Todo.get(params[:id])
    return 404, { success: false, errors: 'Bad todo id.' }.to_json unless todo

    return 403, { success: false, errors: 'Forbidden' }.to_json unless @api_account.id == todo.user_id
    return 200, todo.to_json if todo.update(data)

    errors = []
    todo.errors.each do |e|
      errors << e
    end
    return 400, { success: false, errors: errors }.to_json
  end

  ####
  # Endpoint: DELETE /api/todos/:id
  # Description: Delete todo item
  # Authorization: user
  # Arguments: None
  # Response: json object
  ####
  delete :todo, map: '/api/todos/:id' do
    todo = Todo.get(params[:id])
    return 404, { success: false, errors: 'Bad todo id.' }.to_json unless todo

    return 403, { success: false, errors: 'Forbidden' }.to_json unless @api_account.id == todo.user_id

    return 200, { success: true, content: 'Todo was deleted.' }.to_json if todo.destroy

    errors = []
    todo.errors.each do |e|
      errors << e
    end
    return 400, { success: false, errors: errors }.to_json
  end

  after do
    @api_account = nil
  end
end
