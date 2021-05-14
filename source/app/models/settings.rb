# frozen_string_literal: true

# Class responsible for general application settings
class Settings
  extend Sinclair::EnvSettable

  settings_prefix 'PLAGUE_INC'

  with_settings(
    title: 'Plague Simulations',
    favicon: 'http://images.coronasim.xyz/favicon.ico',
    cache_age: 10.seconds,

    contagion_instants_pagination: 20,

    interaction_block_size: 1000000000,
    processing_iteractions: 1,
    processing_timeout: 2.minutes,
    processing_wait_time: 1.second,

    tmp_plot_folder: '/tmp/plots',

    log_level: :info
  )
end
