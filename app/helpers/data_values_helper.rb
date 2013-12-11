module DataValuesHelper
  def value_field(f, data_type, data_value, name = :value, multiple = false, set_value = false )
    opt = {multiple: multiple}
    opt[:value] = data_value if set_value
    opt[:class] = 'form-control'


    case data_type.name
      when "string_type"
        f.text_field name, opt
      when "text_type"
        f.text_area name, opt
      when "integer_type", "numeric_type"
        f.number_field name, opt
      when "time_type"
        f.time_select name, opt
      when "datetime_type"
        f.datetime_select name, opt
      when "date_type"
        f.date_select name, opt
      else
        f.text_field name, opt
    end
  end


end
