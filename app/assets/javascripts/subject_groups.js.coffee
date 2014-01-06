@subjectGroupsReady = () ->
  null

# Enable addition of subjects by subject group and bulk subject list
$(document).on 'submit', '#subject_addition_tools form', (event) ->

  $.getJSON($(this).attr('action'), $(this).serialize(), (response, status, jqXHR) ->
    console.log(jqXHR.responseText);

    $.each response, (i, item) =>
      $('#subject_group_subject_ids option[value="' + item.id + '"]').prop('selected', true)

    $("select[rel=chosen]").trigger("chosen:updated");
  )

  event.preventDefault()
