#!/bin/env ruby
# frozen_string_literal: true

migration 3, :add_account_status do
  up do
    modify_table :accounts do
      add_column :status, DataMapper::Property::Integer, default: 1
    end
  end

  down do
    drop_column :status
  end
end
