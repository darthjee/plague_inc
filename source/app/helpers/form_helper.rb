module FormHelper
  def bootstrap_input(model, field, placeholder: nil, label: field.capitalize)
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
end
