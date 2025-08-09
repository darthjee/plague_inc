# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'
require 'ostruct'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PlagueInc
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    %w[
      node_modules
      node_modules/bootstrap/dist/css
      node_modules/bootstrap/dist/js
    ].each do |path|
      config.assets.paths << Rails.root.join(*path.split('/'))
    end
  end

  class Application < Rails::Application
    config.active_job.queue_adapter = :sidekiq
  end
end
