#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

# OCMApp Model
class OCMApp
  include DataMapper::Resource
  include DataMapper::Validate

  # Properties
  property :id,                 UUID, key: true, unique_index: true
  property :user_id,            UUID, unique: true
  property :app_install_id,     String, unique: true
  property :api_key,            String
  property :cpdm_user_id,       UUID
  property :username,           String
  property :app_key,            String

  validates_presence_of         :id
  validates_presence_of         :app_install_id
  validates_presence_of         :api_key
  validates_presence_of         :cpdm_user_id
  validates_presence_of         :username
end
