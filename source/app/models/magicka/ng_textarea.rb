# frozen_string_literal: true

module Magicka
  # Element representing a special select that references
  # another list
  class NgTextarea < Magicka::Input
    def ng_errors
      @ng_errors ||= super
    end
  end
end
