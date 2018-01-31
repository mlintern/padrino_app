#!/bin/env ruby
# frozen_string_literal: true

# Account Model
class Account
  include DataMapper::Resource
  include DataMapper::Validate
  attr_accessor :password, :password_confirmation

  # Properties
  property :id,               UUID, key: true
  property :username,         String
  property :name,             String
  property :surname,          String
  property :email,            String
  property :crypted_password, String, length: 70
  property :token,            String
  property :auth_token,       String
  property :role,             String
  property :last_update,      DateTime
  property :last_login,       DateTime
  property :status,           Integer

  # Validations
  validates_presence_of      :username
  validates_presence_of      :password,                          if: :password_required
  validates_presence_of      :password_confirmation,             if: :password_required
  validates_length_of        :password, min: 4, max: 40, if: :password_required
  validates_confirmation_of  :password, if: :password_required
  validates_length_of        :username, min: 3, max: 100
  validates_uniqueness_of    :username, case_sensitive: false
  validates_length_of        :email,    min: 3, max: 100
  validates_format_of        :email,    with: :email_address
  validates_format_of        :role,     with: /[A-Za-z]/

  # Callbacks
  before :save, :encrypt_password
  before :save, :generate_token

  ##
  # This method is for authentication purpose.
  #
  def self.authenticate(username, password)
    account = first(conditions: ['lower(username) = lower(?)', username]) unless username.nil? || username.empty?
    account && account.password?(password) ? account : nil
  end

  def self.token_authenticate(username, token)
    account = first(conditions: ['lower(username) = lower(?)', username]) unless username.nil? || username.empty?
    account && account.token?(token) ? account : nil
  end

  def active?
    status == 1
  end

  def password?(password)
    ::BCrypt::Password.new(crypted_password) == password
  end

  def token?(token)
    token == self.token
  end

  def generate_token
    self.token = SecureRandom.hex if token.nil?
  end

  def generate_uuid
    self.uuid = SecureRandom.uuid if uuid.nil?
  end

  def self.auth_token_authenticate(auth_token)
    first(conditions: ['auth_token = ?', auth_token])
  end

  private

  def password_required
    crypted_password.nil? || password.present?
  end

  def encrypt_password
    self.crypted_password = ::BCrypt::Password.create(password) if password.present?
  end
end
