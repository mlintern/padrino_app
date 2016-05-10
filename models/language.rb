#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

# Language Model
class Language
  include DataMapper::Resource
  include DataMapper::Validate

  # Properties
  property :id,                UUID, key: true, unique_index: true
  property :project_id,        UUID
  property :name,              String
  property :code,              String

  validates_presence_of        :id
  validates_presence_of        :project_id
  validates_presence_of        :name
end
