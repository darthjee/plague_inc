class Magicka::NgSelectText < Magicka::Text
   with_attribute_locals :filter
end

Magicka::Form.with_element(Magicka::Select, :ng_select, template: 'templates/forms/ng_select')
Magicka::Display.with_element(Magicka::NgSelectText, :ng_select)
