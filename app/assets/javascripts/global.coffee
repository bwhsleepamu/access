@setFocusToField = (element_id) ->
  val = $(element_id).val()
  $(element_id).focus().val('').val(val)

# TODO: Might be able to remove this in the future with Turbolinks 5
# https://github.com/turbolinks/turbolinks-classic/issues/455
@fix_ie10_placeholder = ->
  $('textarea').each ->
    if $(@).val() == $(@).attr('placeholder')
      $(@).val ''

@componentsReady = ->
  mainReady()
#  affixReady()
#  graphsReady()
#  textAreaAutocompleteReady()

@extensionsReady = ->
#  clipboardReady()
#  datepickerReady()
#  fileDragReady()
#  tooltipsReady()
#  turbolinksReady()
#  typeaheadReady()

@objectsReady = ->
  dataDictionaryReady()
  documentationsReady()
  sourcesReady()
  studiesReady()
  subjectGroupsReady()
  eventsReady()

@ready = ->
  setFocusToField("#collection_form #s, #search, #s") if $("#collection_form #s, #search, #s").val() != ''
  window.$isDirty = false
  fix_ie10_placeholder()
  componentsReady()
  extensionsReady()
  objectsReady()

$(document).ready(ready)
$(document)
.on('page:load', ready)
.on('page:before-change', -> confirm("You haven't saved your changes.") if window.$isDirty)
.on('click', '[data-object~="suppress-click"]', () ->
  false
)
.on('click', '[data-object~="submit"]', () ->
  window.$isDirty = false
  $($(this).data('target')).submit()
  false
)
.on('click', '[data-object~="hide-target"]', () ->
  $($(this).data('target')).hide()
  false
)
.on('click', '[data-object~="show-target"]', () ->
  $($(this).data('target')).show()
  false
)
.on('click', '[data-object~="toggle-delete-buttons"]', () ->
  $($(this).data('target-show')).show()
  $($(this).data('target-hide')).hide()
  false
)