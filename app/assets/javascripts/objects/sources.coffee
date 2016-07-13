@sourcesReady = () ->
  $.ajax(
    url: document.URL
    dataType: "script"
  )