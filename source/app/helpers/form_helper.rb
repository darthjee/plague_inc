module FormHelper
  def bootstrap_input(model, field, placeholder: nil)
    "<input name='#{field}'
            id='#{field}'
            class='form-control'
            ng-class=\"{'is-invalid': #{model}.errors.#{field}}\"
            ng-model='#{model}.#{field}'
            placeholder='#{placeholder}'
            type='text'>
     <div class='invalid-feedback' ng-repeat='error in #{model}.errors.#{field}'>
        {{error}}
     </div>".html_safe
  end
end
