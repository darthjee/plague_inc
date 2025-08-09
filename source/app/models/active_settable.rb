# frozen_string_literal: true

module ActiveSettable
  include Sinclair::Settable
  extend Sinclair::Settable::ClassMethods

  read_with do |key|
    ActiveSetting.value_for(key)
  end
end
