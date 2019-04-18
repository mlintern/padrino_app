#!/bin/env ruby
# frozen_string_literal: true

PadrinoApp::App.controllers :accounts do
  get :index do
    permission_check('admin')
    session[:redirect_to] = request.fullpath

    @title = 'Accounts'
    account_status_options = { 0 => 'Disabled', 1 => 'Enabled', 2 => 'New' }
    @accounts = if params[:dir] == 'desc'
                  if params[:by]
                    Account.all(order: [params[:by].to_sym.desc]) # desc
                  else
                    Account.all(order: [:username.desc]) # desc
                  end
                elsif params[:by]
                  Account.all(order: [params[:by].to_sym.asc]) # desc
                else
                  Account.all(order: [:username.asc]) # desc
                end
    render 'accounts/index', locals: { 'account_status' => account_status_options, 'accounts' => @accounts, 'account' => current_user }
  end

  get :cards do
    permission_check('admin')
    session[:redirect_to] = request.fullpath

    @title = 'Account Cards'

    # HTTParty.get("http://localhost:3000/api/accounts", :basic_auth => { :username => current_user.username, :password => current_user.token } )

    accounts = Account.all(order: [:surname.asc])
    data = []
    accounts.each do |a|
      user_properties = AccountProperty.all(id: a[:id])
      properties = {}
      user_properties.each do |up|
        properties[up.name.to_sym] = up.value
      end
      user = remove_elements(a.attributes, attributes_to_remove)
      user[:properties] = properties
      data << user
    end
    render 'accounts/cards', locals: { 'accounts' => data, 'account' => current_user }
  end

  get :new do
    permission_check('admin')
    session[:redirect_to] = request.fullpath

    @title = 'New Account'
    account = Account.new
    account.role = '["user"]'
    account.status = 1
    render 'accounts/new', locals: { 'account' => account }
  end

  post :create do
    permission_check('admin')

    params[:account][:last_update] = Time.new.utc
    params[:account][:status] = 0 if params[:account][:status].nil?
    params[:account][:id] = SecureRandom.uuid
    @account = Account.new(params[:account])
    if @account.save
      @title = "Created Account #{@account.username}"
      flash[:success] = 'Account was successfully created' # user flash[:error] when redirecting
      params[:save_and_continue] ? redirect(url(:accounts, :index)) : redirect(url(:accounts, :edit, id: @account.id))
    else
      @title = 'New Account'
      @account.errors.each do |e|
        logger.error("Save Error: #{e}")
        flash.now[:error] = e[0] # User flash.now[:error] when rendering
      end
      params[:account][:role] = '' unless params[:account][:role]
      render 'accounts/new', locals: { 'account' => Account.new(params[:account]) }
    end
  end

  get :edit, with: :id do
    permission_check('user') || permission_check('admin')
    session[:redirect_to] = request.fullpath

    @title = "Editing Account #{params[:id]}"
    @account = Account.get(params[:id])
    photo_url = user_property(params[:id], 'photo').value || '/images/default.png'

    if @account
      session[:redirect_to] = request.fullpath
      render 'accounts/edit', locals: { 'account' => @account, 'photo_url' => photo_url }
    else
      flash[:warning] = "Couldn't Find Account" # user flash[:error] when redirecting
      redirect_last
    end
  end

  put :update, with: :id do
    login

    @title = "Update account #{params[:id]}"

    params[:account][:last_update] = Time.now.utc
    @account = Account.get(params[:id])
    photo_url = user_property(params[:id], 'photo').value || '/images/default.png'
    if @account
      params[:account][:role] = '' if params[:account][:role].nil? && permission_check('admin', false)
      params[:account][:status] = 0 if params[:account][:status].nil? && permission_check('admin', false) && @account.status != 2
      if @account.update(params[:account])
        flash[:success] = "Account #{@account.username} was successfully updated."
        params[:save_and_continue] ? redirect(url(:accounts, :index)) : redirect(url(:accounts, :edit, id: @account.id))
      else
        logger.debug('params[:account] = ' + params[:account].inspect)
        @account.errors.each do |e|
          logger.error("Save Error: #{e}")
          flash.now[:error] = e[0] # User flash.now[:error] when rendering
        end
        render 'accounts/edit', locals: { 'account' => @account, 'photo_url' => photo_url }
      end
    else
      flash[:warning] = 'Account with that ID does not exist.'
      redirect_last
    end
  end

  delete :destroy, with: :id do
    permission_check('admin')

    @title = 'Accounts'
    account = Account.get(params[:id])
    if account
      if (account != current_user) && account.destroy
        flash[:success] = "Account #{params[:id]} was successfully deleted."
      else
        flash[:error] = 'You cannot delete yourself.'
      end
      redirect url(:accounts, :index)
    else
      flash[:warning] = 'User does not exist.'
      halt 404
    end
  end

  delete :destroy_many do
    permission_check('admin')

    @title = 'Accounts'
    unless params[:account_ids]
      flash[:error] = 'You must specify account IDs with account_ids.'
      redirect(url(:accounts, :index))
    end
    ids = params[:account_ids].split(',').map(&:strip)
    accounts = Account.all(id: ids)

    if accounts.include? current_user
      flash[:error] = 'You cannot delete yourself.'
    elsif accounts.destroy
      flash[:success] = "Accounts #{ids.to_sentence} were successfully deleted."
    end
    redirect url(:accounts, :index)
  end
end
