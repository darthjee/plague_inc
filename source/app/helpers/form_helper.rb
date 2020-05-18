# frozen_string_literal: true

module FormHelper
  def bootstrap_input(model, field,
                      placeholder: nil,
                      label: field.to_s.capitalize.gsub(/_/, ' '))
    Form.new(self).bootstrap_input(model, field, placeholder: placeholder, label: label)
  end

  def bootstrap_select(model, field, label: field.capitalize, options: [])
    Form.new(self).bootstrap_select(model, field, label: label, options: options)
  end
end
