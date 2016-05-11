Set up development Database:

cd project/dir
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake db:seed



Set up Prdouction Database on MySQL:

create database with util script:

mysql -uroot utilities/setup_production_db.sql

cd project/dir
RACK_ENV=production padrino rake db:migrate
RACK_ENV=production padrino rake db:seed
chmod 777 db
chmod 777 db/padrino_app_production.db



Setup Redis:

development: brew install redis
production: yum install redis (you may need to install by hand if version is not high enough)


Move Workers initi script:

sudo cp utilities/workers_daemon /etc/init.d/workers_daemon
sudo chmod 755 /etc/init.d/workers_daemon


Start Workers on Production:

sudo service workers_daemon start


Start Workers on Development in forground:

ruby utilities/start_workers.rb


Current Routes:

bundle exec rake routes

Application: PadrinoApp::App
    URL                                      REQUEST  PATH
    (:accounts, :index)                        GET    /accounts
    (:accounts, :cards)                        GET    /accounts/cards
    (:accounts, :new)                          GET    /accounts/new
    (:accounts, :create)                      POST    /accounts/create
    (:accounts, :edit)                         GET    /accounts/edit/:id
    (:accounts, :update)                       PUT    /accounts/update/:id
    (:accounts, :destroy)                    DELETE   /accounts/destroy/:id
    (:accounts, :destroy_many)               DELETE   /accounts/destroy_many
    (:api, :index)                             GET    /api
    (:api, :info)                              GET    /api/info
    (:api, :password)                          GET    /api/password
    (:api, :phrase)                            GET    /api/password/phrase
    (:api, :uuid)                              GET    /api/uuid
    (:api, :external_pub)                      GET    /api/external_pub
    (:api, :external_pub)                     POST    /api/external_pub
    (:api, :debug)                            POST    /api/external_pub/debug
    (:api, :fakedata)                          GET    /api/fakedata
    (:api, :fakedata)                         POST    /api/fakedata
    (:api, :words)                             GET    /api/words
    (:accounts, :index)                        GET    /api/accounts
    (:accounts, :me)                           GET    /api/accounts/me
    (:accounts, :account)                      GET    /api/accounts/:id
    (:accounts, :index)                       POST    /api/accounts
    (:accounts, :account)                      PUT    /api/accounts/:id
    (:accounts, :account)                    DELETE   /api/accounts/:id
    (:todos, :index)                           GET    /api/todos
    (:todos, :index)                          POST    /api/todos
    (:todos, :todo)                            PUT    /api/todos/:id
    (:todos, :todo)                          DELETE   /api/todos/:id
    (:api_translator, :index)                  GET    /api/translator
    (:api_translator, :install)               POST    /api/translator/install
    (:api_translator, :configure)             POST    /api/translator/configure
    (:api_translator, :uninstall)             POST    /api/translator/uninstall
    (:api_translator, :uninstall)              PUT    /api/translator/uninstall
    (:api_translator, :create_project)        POST    /api/translator/create_project
    (:api_translator, :add_source)            POST    /api/translator/add_source
    (:api_translator, :add_source)             PUT    /api/translator/add_source
    (:api_translator, :project_canceled)      POST    /api/translator/project_canceled
    (:api_translator, :get_open_projects)      GET    /api/translator/get_open_projects
    (:api_translator, :id)                   DELETE   /api/translator/:id
    (:api_assets, :index)                      GET    /api/assets/:id
    (:api_assets, :translate)                 POST    /api/assets/:id/translate
    (:api_assets, :index)                    DELETE   /api/assets/:id
    (:api_languages, :index)                   GET    /api/languages/:id
    (:api_languages, :index)                  POST    /api/languages
    (:api_languages, :index)                 DELETE   /api/languages/:id
    (:api_projects, :index)                    GET    /api/projects
    (:api_projects, :index)                   POST    /api/projects
    (:api_projects, :index)                    PUT    /api/projects/:id
    (:api_projects, :index)                    GET    /api/projects/:id
    (:api_projects, :start)                   POST    /api/projects/:id/start
    (:api_projects, :cancel)                  POST    /api/projects/:id/cancel
    (:api_projects, :cancel)                  POST    /api/projects/:id/complete
    (:api_projects, :add)                      GET    /api/projects/:id/assets
    (:api_projects, :add)                     POST    /api/projects/:id/assets
    (:api_projects, :project)                DELETE   /api/projects/:id
    (:base, :index)                            GET    /
    (:curl, :index)                            GET    /curl
    (:curl, :index)                           POST    /curl
    (:sessions, :new)                          GET    /sessions/new
    (:sessions, :signup)                      POST    /sessions/signup
    (:sessions, :create)                      POST    /sessions/create
    (:sessions, :destroy)                      GET    /sessions/destroy
    (:translator, :index)                      GET    /translator
    (:translator, :configure)                 POST    /translator/configure
    (:translator, :configure)                  GET    /translator/configure
    (:translator, :project)                    GET    /translator/project/:id
    (:translator, :asset)                      GET    /translator/asset/:id


Seeded Users:

administrator - admin,curl
mweston - user,curl
fglenanne - user,admin
saxe - 
jporter - curl
maddie - user
nweston - user
barry - user

password is 'password'

To use email you will want to create a file on the root of hte project called env.rb, which should look like this:

ENV['GMAIL_EMAIL'] = 'emailaddress@gamil.com'
ENV['GMAIL_PASSWORD'] = 'passwordtoemailaddress'

# Testing Environment Variables
ENV['NRETNIL_ADMIN_USERNAME'] = '__selenium_admin'
ENV['NRETNIL_ADMIN_PASSWORD'] = 'password'
ENV['NRETNIL_USER_ONE_USERNAME'] = '__selenium_user_one'
ENV['NRETNIL_USER_ONE_PASSWORD'] = 'password'
ENV['NRETNIL_USER_TWO_USERNAME'] = '__selenium_user_one'
ENV['NRETNIL_USER_TWO_PASSWORD'] = 'password'
ENV['TARGET_URL'] = 'localhost:3000'
ENV['TIMEOUT'] = '10'

