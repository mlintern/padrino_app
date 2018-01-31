#!/bin/env ruby
# frozen_string_literal: true

PadrinoApp::App.controllers :sessions do
  get :new do
    render '/sessions/new', layout: 'minimal'
  end

  post :signup do
    form_params = params

    params[:last_update] = Time.new.utc
    params[:status] = 2
    params[:id] = SecureRandom.uuid
    params[:password] = params[:password_confirmation] = Nretnil::Password.generate(10)[:password]
    params[:role] = ['user']
    @account = Account.new(params)
    if @account.save
      flash.now[:success] = 'Your Account has been saved.  You will recieve an email with credentials shortly.' # user flash[:error] when redirecting
      flash[:success] = 'Your Account has been saved.  You will recieve an email with credentials shortly.' # user flash[:error] when redirecting

      begin
        email(
          from: 'donotreply@nretnil.com',
          to: params[:email],
          subject: 'New User Information',
          content_type: :html,
          body: render('email/newuser', layout: false, locals: { 'user' => params })
        )
      rescue StandardError => e
        logger.error(e)
        logger.error('Email did not send')
      end

      redirect url(:sessions, :new), 302
    else
      errors = ''
      @account.errors.each do |error|
        logger.error("Save Error: #{error}")
        errors += error[0] + ' '
      end
      flash.now[:error] = errors
      flash[:error] = errors
      redirect url(:sessions, :new), 302, form_params
    end
  end

  post :create do
    account = Account.authenticate(params[:username], params[:password])
    if account
      if account.status.zero?
        flash[:error] = 'Account is Disabled'
        logger.info('Account is Disabled')
        redirect url(:sessions, :new), 302
      else
        token = SecureRandom.hex
        account.update(token: token, last_login: Time.now.utc)
        expire_time = Time.now.utc + 30 * 60
        expire_time += (24 * 60 * 60) - (30 * 60) if params[:remember_me]
        response.set_cookie('user', value: token, path: '/', expires: expire_time) if account
        if account.status == 2
          account.update(status: 1)
          flash[:notice] = 'You should update your password!'
          redirect '/accounts/edit/' + account.id.to_s
        else
          redirect_last
        end
      end
    else
      flash[:error] = 'Username or Password is wrong'
      logger.info('Username or Password is Wrong')
      redirect url(:sessions, :new), 302
    end
  end

  get :destroy do
    response.delete_cookie('user', path: '/')
    session[:user] = nil
    session[:errors] = nil
    session[:redirect_to] = nil
    flash[:error] = nil
    flash[:success] = nil
    redirect url(:base, :index)
  end
end
