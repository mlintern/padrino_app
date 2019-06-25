#!/bin/env ruby
# frozen_string_literal: true

PadrinoApp::App.helpers do
  ####
  # Name: create_path_if_not_exist
  # Description: takes an path on the filesystem and creates it if it does not exist
  # Arguments: path
  # Response: boolean
  ####
  def create_path_if_not_exist(path)
    FileUtils.mkdir_p(path) unless File.directory?(path)
  end
end
