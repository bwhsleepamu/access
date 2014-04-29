# Page Load Actions
@mainReady = () ->
  $("select[rel=chosen]").chosen
    allow_single_deselect: true
    no_results_text: 'No results matched'
    width: '100%'
  $(".chosen").chosen
    allow_single_deselect: true
    no_results_text: 'No results matched'
    width: '100%'

  ## Markdown Functionality
  $("form textarea").each( (index, textarea) ->
    panel = $("<did/>", {
      "class": "wmd-panel"
    })

    $(textarea).after($("<div/>", {
      "id": "wmd-preview-"+index
      "class": "wmd-panel wmd-preview"
    }))
    $(textarea).after($("<h5/>", {
      text: "Preview:"
    }))

    $(textarea).attr("id", "wmd-input-"+index)
    $(textarea).addClass("wmd-input-"+index)
    $(textarea).wrap(panel)
    $(textarea).before($("<div/>", {
      "id": "wmd-button-bar-"+index
    }))


    conv = Markdown.getSanitizingConverter();
    ed = new Markdown.Editor(conv, "-"+index )
    ed.run();
  )

# Event Handler Definitions



#@



## Index Functionality
jQuery.fn.reset_index = () ->
  $(".index-content").html("")
  $("#ajax_loader").show()


$(document).on("click", ".form-search .submit-button", () ->
  jQuery.fn.reset_index()
  $(".form-search").submit()
  false
)

$(document).off("click", ".per_page a")
$(document).on("click", ".per_page a", () ->
  jQuery.fn.reset_index()
  $($(this).data('form')).find("#per_page").val($(this).data('per-page'))
  $($(this).data('form')).submit()
  false
)

$(document).off("click", '[data-object~="order"]')
$(document).on('click', '[data-object~="order"]', () ->
  $($(this).data('form')).find("#order").val($(this).data('order'))
  jQuery.fn.reset_index()
  $($(this).data('form')).submit()
  false
)

$(document).off('click', ".pagination a, .page a, .first a, .last a, .next a, .prev a")
$(document).on('click', ".page a, .first a, .last a, .next a, .prev a", () ->
  return false if $(this).parent().is('.active, .disabled, .per_page')
  jQuery.fn.reset_index()
  $.get(this.href, null, null, "script")
  false
)

