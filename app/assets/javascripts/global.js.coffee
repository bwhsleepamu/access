## These functions need to run on a page load - whether through turbolinks or full page refresh
@loaders = () ->
  contourReady()
  mainReady()
  dataDictionaryReady()
  documentationsReady()
  sourcesReady()
  studiesReady()
  subjectGroupsReady()


## The two options (turbolinks, full page refresh) are adressed here
$(document).ready(loaders)
$(document).on('page:load', loaders)