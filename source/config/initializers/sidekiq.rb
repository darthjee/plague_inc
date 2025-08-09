# frozen_string_literal: true

redis_url = if ENV['REDISCLOUD_URL'].present?
              ENV['REDISCLOUD_URL']
            else
              ENV.fetch('PLAGUE_INC_REDIS_URL', nil)
            end

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end
