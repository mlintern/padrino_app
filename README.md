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
    (:sessions, :new)               GET    /sessions/new
    (:sessions, :signup)           POST    /sessions/signup
    (:sessions, :create)           POST    /sessions/create
    (:sessions, :destroy)           GET    /sessions/destroy
    (:accounts, :index)             GET    /accounts
    (:accounts, :cards)             GET    /accounts/cards
    (:accounts, :new)               GET    /accounts/new
    (:accounts, :create)           POST    /accounts/create
    (:accounts, :edit)              GET    /accounts/edit/:id
    (:accounts, :update)            PUT    /accounts/update/:id
    (:accounts, :destroy)         DELETE   /accounts/destroy/:id
    (:accounts, :destroy_many)    DELETE   /accounts/destroy_many
    (:accounts, :index)             GET    /api/accounts
    (:accounts, :me)                GET    /api/accounts/me
    (:accounts, :account)           GET    /api/accounts/:id
    (:accounts, :index)            POST    /api/accounts
    (:accounts, :account)           PUT    /api/accounts/:id
    (:accounts, :account)         DELETE   /api/accounts/:id
    (:base, :index)                 GET    /
    (:api, :index)                  GET    /api
    (:api, :info)                   GET    /api/info
    (:api, :password)               GET    /api/password
    (:api, :phrase)                 GET    /api/password/phrase
    (:api, :external_pub)          POST    /api/external_pub
    (:api, :debug)                 POST    /api/external_pub/debug
    (:todos, :index)                GET    /api/todos
    (:todos, :index)               POST    /api/todos
    (:todos, :todo)                 PUT    /api/todos/:id
    (:todos, :todo)               DELETE   /api/todos/:id
    (:curl, :index)                 GET    /curl
    (:curl, :index)                POST    /curl


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

