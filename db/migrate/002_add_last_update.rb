#!/bin/env ruby
# frozen_string_literal: true

migration 2, :add_last_update do
  up do
    modify_table :accounts do
      add_column :last_update, DataMapper::Property::DateTime, allow_nil: true
    end
  end

  down do
    drop_column :last_update
  end
end
