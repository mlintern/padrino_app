#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

# AccountProperty Model
class AccountProperty
  include DataMapper::Resource
  include DataMapper::Validate

  # Properties
  property :id,               UUID, key: true, unique_index: false
  property :name,             String
  property :value,            String

  validates_presence_of       :id
  validates_presence_of       :name
end
