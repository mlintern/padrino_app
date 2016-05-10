#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

migration 7, :ocm_apps do
  up do
    create_table :ocm_apps do
      column :id, DataMapper::Property::UUID
      column :user_id, DataMapper::Property::UUID
      column :app_install_id, DataMapper::Property::String
      column :api_key, DataMapper::Property::String
      column :cpdm_user_id, DataMapper::Property::UUID
      column :username, DataMapper::Property::String
      column :app_key, DataMapper::Property::String
    end
  end

  down do
    drop_table :ocmapp
  end
end
