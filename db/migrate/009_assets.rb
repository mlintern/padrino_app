#!/bin/env ruby
# frozen_string_literal: true

migration 5, :assets do
  up do
    create_table :assets do
      column :id, DataMapper::Property::UUID
      column :project_id, DataMapper::Property::String, length: 255
      column :external_id, DataMapper::Property::UUID
      column :title, DataMapper::Property::String, length: 255
      column :body, DataMapper::Property::Text
      column :source, DataMapper::Property::Boolean
      column :source_id, DataMapper::Property::UUID
      column :status, DataMapper::Property::Integer
      column :language, DataMapper::Property::String, length: 255
    end
  end

  down do
    drop_table :assets
  end
end
