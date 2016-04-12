module Sidekiq
  class CLI
    private

    def print_banner
      # banner taking up all my screen :)
    end
  end
end

class SidekiqWebInterface < Sidekiq::Web
  class << self
    def dependencies; []; end
    def setup_application!; end
    def reload!; end
  end
end