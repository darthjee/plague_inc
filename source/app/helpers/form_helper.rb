# frozen_string_literal: true

module FormHelper
  def bootstrap_form(model)
    yield Magicka::Form.new(self, model)
  end

  def bootstrap_display(model)
    yield Magicka::Display.new(self, model)
  end
end
