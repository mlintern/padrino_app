#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

migration 4, :project_properties do
  up do
    create_table :project_properties do
      column :id, DataMapper::Property::UUID
      column :name, DataMapper::Property::String, length: 255
      column :value, DataMapper::Property::String, length: 255
    end
  end

  down do
    drop_table :project_properties
  end
end
