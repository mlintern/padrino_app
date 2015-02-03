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



Current Routes:

bundle exec rake routes

Application: PadrinoApp::App
    URL                           REQUEST  PATH
    (:accounts, :index)             GET    /accounts
    (:accounts, :new)               GET    /accounts/new
    (:accounts, :create)           POST    /accounts/create
    (:accounts, :edit)              GET    /accounts/edit/:id
    (:accounts, :update)            PUT    /accounts/update/:id
    (:accounts, :destroy)         DELETE   /accounts/destroy/:id
    (:accounts, :destroy_many)    DELETE   /accounts/destroy_many
    (:api, :index)                  GET    /api
    (:api, :accounts)               GET    /api/accounts
    (:api, :me)                     GET    /api/accounts/me
    (:api, :info)                   GET    /api/info
    (:base, :index)                 GET    /
    (:sessions, :new)               GET    /sessions/new
    (:sessions, :create)           POST    /sessions/create
    (:sessions, :destroy)           GET    /sessions/destroy



Seeded Users:

administrator - admin
mweston - user
fglenanne - user
saxe - user
jporter - user

password is 'password'