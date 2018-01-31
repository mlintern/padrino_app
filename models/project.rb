#!/bin/env ruby
# frozen_string_literal: true

# Project Model
class Project
  include DataMapper::Resource
  include DataMapper::Validate

  # Properties
  property :id,                 UUID, key: true, unique_index: true
  property :user_id,            UUID
  property :name,               String
  property :description,        Text
  property :status,             Integer, default: 0
  property :language,           String
  property :type,               Integer, default: 0

  validates_presence_of         :id
  validates_presence_of         :user_id
  validates_presence_of         :name
  validates_presence_of         :language
end
