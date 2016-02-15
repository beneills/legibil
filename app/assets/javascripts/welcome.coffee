# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# https://gist.github.com/dperini/729294
# Single regex change: allow dropping protocol component
validUrl = (url) ->
  /^(?:(?:https?):\/\/)?(?:\S+(?::\S*)?@)?(?:(?!(?:10|127)(?:\.\d{1,3}){3})(?!(?:169\.254|192\.168)(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)(?:\.(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)*(?:\.(?:[a-z\u00a1-\uffff]{2,}))\.?)(?::\d{2,5})?(?:[/?#]\S*)?$/i.test( url )

jQuery ->

  # Provide real-time feedback to user on URL validity
  $('#endpoint_url').on 'input', ->
    url = $(this).val()
    if url.length
      if validUrl(url)
        $(this).css('background-color', '#DDFFDD')
      else
        $(this).css('background-color', '#FFDDDD')
    else
      $(this).css('background-color', 'white')

  # Hot-switch endpoints and new endpoint form
  $(".endpoint-selector").on 'click', ->
    endpoint_class_list = $(this).attr("class").split(/\s+/).filter (x) -> /endpoint-\d+/.test(x)
    if endpoint_class_list.length != 1
      console.log("Error in CSS: element does not have unique endpoint identifier: " + $(this).attr("class"))
    else
      endpoints_to_show_css = ".one-of-many." + endpoint_class_list[0]

      $(".one-of-many").fadeOut("fast")
      $(endpoints_to_show_css).fadeIn("fast")
  $("#endpoint-new-selector").on 'click', ->
      $(".one-of-many").fadeOut("fast")
      $("#endpoint-new").fadeIn("fast")

  # Show/hide endpoint name change form
  $(".endpoint-name-change").on 'click', ->
    if $(".endpoint-name-change-form").css("display") != "none"
      $(".endpoint-name-change-form").fadeOut("fast")
    else
      $(".endpoint-name-change-form").fadeIn("fast")
  $(".endpoint-name-change-cancel").on 'click', ->
    $(".endpoint-name-change-form").fadeOut("fast")


# Upon DOM ready
$ ->

  # Select one of the hot-switchable elements by default
  $(".selected-default").fadeIn("fast")
