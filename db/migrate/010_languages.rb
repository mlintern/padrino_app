#!/bin/env ruby
# frozen_string_literal: true

migration 6, :languages do
  up do
    create_table :languages do
      column :id, DataMapper::Property::UUID
      column :project_id, DataMapper::Property::UUID
      column :name, DataMapper::Property::String, length: 255
      column :code, DataMapper::Property::String, length: 255
    end
  end

  down do
    drop_table :assets
  end
end
