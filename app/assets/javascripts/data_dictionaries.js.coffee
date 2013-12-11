# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
AttributeForm =
  value_field: null
  set_value_field: (value_field_html) ->
    AttributeForm.value_field = "<li>" + value_field_html + "</li>" #"<h3>yo mama</h3>" #value_field_html
  update_form: () ->
    data_type_id = $("#data_dictionary_data_type_id").val()
    data_dictionary_id = $("form#data_dictionary").data("data-dictionary-id")
    attr_div = $("#data_attributes")
    form_path = $("form#data_dictionary").data("form-path")

    attr_div.hide()
    if data_type_id != ""
      attr_div.load(
        #"/data_dictionary/data_attribute_form",
        form_path,
        { data_dictionary_id: data_dictionary_id, data_type_id: data_type_id },
        () ->
          AttributeForm.activate_values_buttons()
          attr_div.show('fast')
      )
  add_value_field: () ->
    $("#value_fields ol").append(AttributeForm.value_field)

    false
  remove_value_field: () ->
    $(this).closest("li").remove()
    false
  activate_values_buttons: () ->
    AttributeForm.set_value_field($("#value_fields ol li:last").html())
    #$("#data_dictionary_multivalue").chosen()

# On page load
jQuery ->
  $('#data_dictionary_data_type_id').chosen().change(AttributeForm.update_form)
  $(document).on "click", "#value_fields .remove", AttributeForm.remove_value_field
  $(document).on "click", "#value_fields #add_value_field", AttributeForm.add_value_field
  AttributeForm.update_form()
