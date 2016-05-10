#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

migration 12, :modify_accounts do
  up do
    modify_table :accounts do
      add_column :auth_token, DataMapper::Property::String, length: 255
    end
  end

  down do
    drop_table :accounts
  end
end
