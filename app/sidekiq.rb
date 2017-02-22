#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

module Sidekiq
  # CLI Class
  class CLI
    private

    def print_banner
      # banner taking up all my screen :)
    end
  end
end

# Sidekick Web Interface App
class SidekiqWebInterface < Sidekiq::Web
  class << self
    def dependencies
      []
    end

    def setup_application!; end

    def reload!; end
  end
end
