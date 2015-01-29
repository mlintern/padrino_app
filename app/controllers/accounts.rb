PadrinoApp::App.controllers :accounts do
  get :index do
    admin
    session[:redirect_to] = request.fullpath

    @title = "Accounts"
    @accounts = Account.all
    render 'accounts/index'
  end

  get :new do
    admin
    session[:redirect_to] = request.fullpath

    @title = pat(:new_title, :model => 'account')
    @account = Account.new
    @account.role = ""
    render 'accounts/new', :locals => { 'account' => @account }
  end

  post :create do
    admin

    params[:account][:last_update] = DateTime.now
    @account = Account.new(params[:account])
    if @account.save
      @title = pat(:create_title, :model => "account #{@account.id}")
      flash[:success] = "Account was successfully created" # user flash[:error] when redirecting
      params[:save_and_continue] ? redirect( url( :accounts, :index ) ) : redirect( url( :accounts, :edit, :id => @account.id ) )
    else
      @title = pat(:create_title, :model => 'account')
      @account.errors.each do |e|
        logger.error("Save Error: #{e}")
        flash.now[:error] = e[0] # User flash.now[:error] when rendering
      end
      render 'accounts/new', :locals => { 'account' => @account }
    end
  end

  get :edit, :with => :id do
    admin? || ( login && owner?(params[:id]) )

    @title = pat(:edit_title, :model => "account #{params[:id]}")
    @account = Account.get(params[:id])
    if @account
      session[:redirect_to] = request.fullpath
      render 'accounts/edit', :locals => { 'account' => @account }
    else
      flash[:warning] = "Couldn't Find Account" # user flash[:error] when redirecting
      # halt 404
      redirect_last
    end
  end

  put :update, :with => :id do
    login

    @title = pat(:update_title, :model => "account #{params[:id]}")
    
    params[:account][:last_update] = DateTime.now
    @account = Account.get(params[:id])
    if @account
      params[:account][:role] = "" if ( params[:account][:role].nil? && admin? )
      if @account.update(params[:account])
        flash[:success] = "Account with id #{params[:id]} was successfully updated."
        params[:save_and_continue] ? redirect(url(:accounts, :index)) : redirect(url(:accounts, :edit, :id => @account.id))
      else
        @account.errors.each do |e|
          logger.error("Save Error: #{e}")
          flash.now[:error] = e[0] # User flash.now[:error] when rendering
        end
        render 'accounts/edit', :locals => { 'account' => @account }
      end
    else
      flash[:warning] = "Account with that ID does not exist."
      # halt 404
      redirect_last
    end
  end

  delete :destroy, :with => :id do
    admin

    @title = "Accounts"
    account = Account.get(params[:id])
    if account
      if account != current_account && account.destroy
        flash[:success] = "Account #{params[:id]} was successfully deleted."
      else
        flash[:error] = "You cannot delete yourself."
      end
      redirect url(:accounts, :index)
    else
      flash[:warning] = "User does not exist."
      halt 404
    end
  end

  delete :destroy_many do
    admin
    
    @title = "Accounts"
    unless params[:account_ids]
      flash[:error] = "You must specify account IDs with account_ids."
      redirect(url(:accounts, :index))
    end
    ids = params[:account_ids].split(',').map(&:strip)
    accounts = Account.all(:id => ids)
    
    if accounts.include? current_account
      flash[:error] = "You cannot delete yourself."
    elsif accounts.destroy
      flash[:success] = "Accounts #{ids.to_sentence} were successfully deleted."
    end
    redirect url(:accounts, :index)
  end
end
