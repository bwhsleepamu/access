$ =>
  $('#documentation_form').on 'click', '.remove-link', (event) ->
    $(this).prev('input[type=hidden]').val('1')
    $(this).closest('fieldset').hide()
    event.preventDefault()


  $('#documentation_form').on 'click', '.add-links', (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('fields').replace(regexp, time))
    event.preventDefault()

#
#$(document).ready ->
#  $("#documentations").infinitescroll
#    navSelector: "nav.pagination" # selector for the paged navigation (it will be hidden)
#    nextSelector: "nav.pagination a[rel=next]" # selector for the NEXT link (to page 2)
#    itemSelector: "#documentation tr.post" # selector for all items you'll retrieve
