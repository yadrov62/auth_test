require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Auth
  class Application < Rails::Application
    config.load_defaults 7.1

    # Set timezone
    config.time_zone = "UTC"

    # Autoload lib directory
    config.autoload_lib(ignore: %w[assets tasks])

    # Generator settings
    config.generators do |g|
      g.test_framework :test_unit, fixture: true
      g.fixture_replacement :test_unit
    end
  end
end

