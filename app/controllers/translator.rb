PadrinoApp::App.controllers :translator do
  get :index do
    permission_check('translate')
    session[:redirect_to] = request.fullpath

    @title = "Projects"

    projects = Project.all( :user_id => current_user.id, :order => [ :name.asc ] )
    counts = {}
    dest_languages = {}
    projects.each do |project|
      project_languages = Language.all({ :project_id => project.id })
      source_assets = Asset.all({ :project_id => project.id, :source => true })
      translated_assets = Asset.all({ :project_id => project.id, :source => false })
      counts[project.id] = { :source => source_assets.count, :translated => translated_assets.count }
      dest_languages[project.id] = project_languages
    end

    render 'translator/index', :locals => { 'projects' => projects, 'counts' => counts, 'status' => ["Open","In Progress","Canceled","Complete"], :dest_languages => dest_languages, :ocmapp => OCMApp.first({ :user_id => current_user.id })  }
  end

  post :configure do
    session[:redirect_to] = request.fullpath + params_to_url(params,["username","password"])
    if account = Account.authenticate(params[:username], params[:password])
      if account.role["translate"]
        unless account.status == 0
          user_ocmapp = OCMApp.first({ :user_id => account.id })
          if user_ocmapp && user_ocmapp.app_install_id != params["app_install_id"]
            flash[:error] = "#{account.username} already has an app installed"
            redirect_last
          else
            unless params['app_install_id'].nil?
              ocmapp = OCMApp.first({ :app_install_id => params['app_install_id'] })
              if ocmapp
                if ocmapp.update({ :user_id => account.id })
                  data = { :success => true, :configured =>  true }
                  url = params["configuration_confirm_url"]
                  # if url.include? "app.test-cpdm.oraclecorp.com" # Update Url for Ngrok
                  #   url = url.gsub("app.test-cpdm.oraclecorp.com","wh_notifier:reNdN3Ykh3uCwWra@3db356e5.ngrok.io")
                  # elsif url.include? "dev.cpdm.oraclecorp.com" # Update Url for Ngrok
                  #   url = url.gsub("dev.cpdm.oraclecorp.com","78834bbf.ngrok.io")
                  # end
                  logger.debug url
                  if post_callback_auth(url, data, ocmapp.username, ocmapp.api_key)
                    erb '<div class="text-center"><h3>Configuration Complete</h3></div>', :layout => 'minimal'
                  else
                    erb '<div class="text-center"><h3>Configuration Failed</h3></div>', :layout => 'minimal'
                  end
                else
                  errors = []
                  ocmapp.errors.each do |e|
                    errors << e
                  end
                  flash[:error] = errors
                  redirect_last
                end
              else
                flash[:error] = "App not found"
                redirect_last
              end
            else
              flash[:error] = "App Install ID not provided"
              redirect_last
            end
          end
        else
          flash[:error] = "Account is disabled"
          redirect_last
        end
      else
        flash[:error] = "#{account.username} does not have rights to use translator app"
        redirect_last
      end
    else
      flash[:error] = "Username or Password is wrong"
      redirect_last
    end
  end

  get :configure do
    session[:redirect_to] = request.fullpath

    render 'translator/configure', :layout => 'minimal', :locals => { :params => params }
  end

  get :project, :map => 'translator/project/:id' do
    permission_check('translate')

    project = Project.get(params[:id])
    if project
      session[:redirect_to] = request.fullpath
      languages = Language.all( :project_id => project.id )

      if current_user.id == project.user_id
        assets = Asset.all( :project_id => project.id )

        @title = project.name
        can_complete = true
        assets.each do |a|
          can_complete = false if a.status == 0
        end

        render 'translator/project', :locals => { 'project' => project, 'assets' => assets, 'back' => '/translator', 'status' => ["Ready","Completed","Translated Asset","Error Translating"], :languages => languages, :can_complete => can_complete }
      else
        flash[:error] = "You do not have permission to view project."
        redirect_last
      end
    else
      flash[:warning] = "Project does not exist."
      redirect_last
    end
  end

  get :asset, :map => 'translator/asset/:id' do
    permission_check('translate')

    asset = Asset.get(params[:id])
    if asset
      project = Project.get(asset.project_id)
      session[:redirect_to] = request.fullpath
      if current_user.id == project.user_id
        @title = asset.title

        render 'translator/asset', :locals => { 'asset' => asset, 'project' => project , 'back' => '/translator/project/'+project.id }
      else
        flash[:error] = "You do not have permission to view asset."
        redirect_last
      end
    else
      flash[:warning] = "Asset does not exist."
      redirect_last
    end
  end
end