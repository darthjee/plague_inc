# frozen_string_literal: true

class Sinclair
  module Settable
    class Caster
      cast_with(:seconds) { |value| value.to_i.seconds }
      cast_with(:boolean) { |value| value.to_s.downcase == 'true' }
    end
  end
end

# Class responsible for general application settings
class Settings
  extend Sinclair::ChainSettable

  source :env, EnvSettings
  source :db,  ActiveSettings

  with_settings(
    :password_salt,
    title: 'Plague Simulations',
    favicon: 'http://images.coronasim.xyz/favicon.ico',
    cache_age: 10.seconds,

    contagion_instants_pagination: 20,

    interaction_block_size: 1000,
    processing_iteractions: 1,
    processing_timeout: 2.minutes,
    processing_wait_time: 1.second,

    tmp_plot_folder: '/tmp/plots',

    log_level: :info
  )
  setting_with_options(:hex_code_size, default: 16, type: :integer)
  setting_with_options(:session_period, default: 2.days, type: :seconds)
  setting_with_options(:background_worker, default: true, type: :boolean)
end
