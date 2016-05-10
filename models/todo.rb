#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

# Todo Model
class Todo
  include DataMapper::Resource
  include DataMapper::Validate

  # Properties
  property :id,               UUID, key: true
  property :title,            String
  property :user_id,          UUID
  property :completed,        Boolean, default: false

  validates_uniqueness_of     :id, case_sensitive: false
  validates_presence_of       :title
  validates_presence_of       :user_id
end
