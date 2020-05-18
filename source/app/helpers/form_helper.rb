# frozen_string_literal: true

module FormHelper
  def bootstrap_input(model, field, placeholder: nil, label: field.to_s.capitalize.gsub(/_/,' '))
    locals = {
      label: label,
      ng_errors: [model, :errors, field].join('.'),
      ng_model: [model, field].join('.'),
      model: model,
      field: field,
      placeholder: placeholder
    }

    render partial: 'templates/forms/input', locals: locals
  end

  def bootstrap_select(model, field, label: field.capitalize, options: [])
    locals = {
      label: label,
      ng_errors: [model, :errors, field].join('.'),
      ng_model: [model, field].join('.'),
      model: model,
      field: field,
      options: options
    }

    render partial: 'templates/forms/select', locals: locals
  end
end
