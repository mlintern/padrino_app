require "securerandom"

class Account
  include DataMapper::Resource
  include DataMapper::Validate
  attr_accessor :password, :password_confirmation

  # Properties
  property :id,               Serial
  property :username,         String
  property :name,             String
  property :surname,          String
  property :email,            String
  property :crypted_password, String, :length => 70
  property :token,            String
  property :role,             String
  property :last_update,      DateTime

  # Validations
  validates_presence_of      :username
  validates_presence_of      :password,                          :if => :password_required
  validates_presence_of      :password_confirmation,             :if => :password_required
  validates_length_of        :password, :min => 4, :max => 40,   :if => :password_required
  validates_confirmation_of  :password,                          :if => :password_required
  validates_length_of        :username, :min => 3, :max => 100
  validates_uniqueness_of    :username, :case_sensitive => false
  validates_length_of        :email,    :min => 3, :max => 100
  validates_format_of        :email,    :with => :email_address
  validates_format_of        :role,     :with => /[A-Za-z]/

  # Callbacks
  before :save, :encrypt_password
  before :save, :generate_token

  ##
  # This method is for authentication purpose.
  #
  def check
    puts " * * * * Check * * * * "
  end

  def self.authenticate(username, password)
    account = first(:conditions => ["lower(username) = lower(?)", username]) if username.present?
    account && account.has_password?(password) ? account : nil
  end

  ##
  # This method is used by AuthenticationHelper
  #
  def self.find_by_id(id)
    get(id) rescue nil
  end

  def has_password?(password)
    ::BCrypt::Password.new(crypted_password) == password
  end

  def generate_token
    self.token = SecureRandom.hex if self.token.nil?
  end

  private

  def password_required
    crypted_password.blank? || password.present?
  end

  def encrypt_password
    # puts " * * * * * Encrypting Password * * * * * "
    self.crypted_password = ::BCrypt::Password.create(password) if password.present?
  end
end
