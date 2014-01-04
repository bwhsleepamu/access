# Page Load Actions
@documentationsReady = () ->
  null

# Event Handler Definitions
$(document).on 'click', '#documentation_form .remove-link', (event) ->
  $(this).prev('input[type=hidden]').val('1')
  $(this).closest('fieldset').hide()
  event.preventDefault()

$(document).on 'click', '#documentation_form .add-links', (event) ->
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
