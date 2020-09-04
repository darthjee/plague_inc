# frozen_string_literal: true

# Class responsible for general application settings
class Settings
  extend Sinclair::EnvSettable

  settings_prefix 'PLAGUE_INC'

  with_settings(
    title: 'Plague Simulations',
    favicon: 'http://images.coronasim.xyz/favicon.ico',
    cache_age: 10.seconds,
    interaction_block_size: 1000,
    processing_timeout: 2.minutes,
    contagion_instants_pagination: 20
  )
end
