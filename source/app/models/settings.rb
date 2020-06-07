# frozen_string_literal: true

class Settings
  extend Sinclair::EnvSettable

  settings_prefix 'PLAGUE_INC'

  with_settings(
    title: 'Plague Simulations',
    cache_age: 10.seconds
  )
end
