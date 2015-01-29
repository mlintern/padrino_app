Set up Prdouction Database:

RACK_ENV=production bundle exec rake db:create
RACK_ENV=production bundle exec rake db:migrate
RACK_ENV=production bundle exec rake db:seed


Current Routes:

bundle exec rake routes

Application: PadrinoApp::App
    URL                           REQUEST  PATH
    (:sessions, :new)               GET    /sessions/new
    (:sessions, :create)           POST    /sessions/create
    (:sessions, :destroy)           GET    /sessions/destroy
    (:accounts, :index)             GET    /accounts
    (:accounts, :new)               GET    /accounts/new
    (:accounts, :create)           POST    /accounts/create
    (:accounts, :edit)              GET    /accounts/edit/:id
    (:accounts, :update)            PUT    /accounts/update/:id
    (:accounts, :destroy)         DELETE   /accounts/destroy/:id
    (:accounts, :destroy_many)    DELETE   /accounts/destroy_many
    (:base, :index)                 GET    /
    (:api, :index)                  GET    /api
    (:api, :info)                   GET    /api/info



Seeded Users:

administrator - admin
mweston - user
fglenanne - user
saxe - user
jporter - user

password is 'password'