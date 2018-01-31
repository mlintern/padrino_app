#!/bin/env ruby
# frozen_string_literal: true

migration 4, :create_account_properties do
  up do
    create_table :account_properties do
      column :id, DataMapper::Property::UUID
      column :name, DataMapper::Property::String, length: 255
      column :value, DataMapper::Property::String, length: 255
    end
  end

  down do
    drop_table :account_properties
  end
end
