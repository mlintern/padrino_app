#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

migration 13, :add_project_type do
  up do
    modify_table :projects do
      add_column :type, DataMapper::Property::Integer, default: 0
    end
  end

  down do
    drop_column :accounts
  end
end
