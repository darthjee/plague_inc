# frozen_string_literal: true

module FormHelper
  def bootstrap_form
    yield Form.new(self)
  end
end
