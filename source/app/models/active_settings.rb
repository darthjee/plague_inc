# frozen_string_literal: true

class ActiveSettings
  extend ActiveSettable

  with_settings(
    :password_salt,
    :hex_code_size,
    :session_period,
    :cache_age,
    :title,
    :favicon
  )
end
