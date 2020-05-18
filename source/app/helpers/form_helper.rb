# frozen_string_literal: true

module FormHelper
  def bootstrap_form(model)
    yield Form.new(self, model)
  end
end
