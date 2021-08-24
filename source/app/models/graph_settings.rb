# frozen_string_literal: true

# Class responsible for general application settings
class GraphSettings
  extend Sinclair::EnvSettable

  settings_prefix 'GRAPH'

  with_settings(
    :host,
    :username,
    :key,
    :folder,
  )
 end

