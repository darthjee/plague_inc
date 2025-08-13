# frozen_string_literal: true

class EnvSettings
  extend Sinclair::EnvSettable

  settings_prefix 'PLAGUE_INC'

  with_settings(
    :password_salt,
    :hex_code_size,
    :session_period,
    :cache_age,
    :title,
    :favicon,
    :contagion_instants_pagination,
    :interaction_block_size,
    :processing_iteractions,
    :processing_timeout,
    :processing_wait_time,
    :tmp_plot_folder,
    :log_level,
    :background_worker
  )
end
