itemsFormatResults = (item) ->
  markup = "<div class=\"row\">" +
  "<div class=\"columns large-2\"><img src=\"/assets/groceries/plate7.png\"</img></div>" +
  "<div class=\"columns large-10\"><div class=\"row\"><div>" + item.name + "</div></div>" +
  "<div class=\"row\"><div>" + item.description + "</div></div></div>"

itemsFormatSelection = (item) ->
  item.name

$(document).ready ->
  $('#grocery_name').select2
    placeholder: "Add grocery items."
    minimumInputLength: 1
    multiple: true
    ajax:
      url: "/groceries/2/auto_complete"
      dataType: "json"
      quietMillis: 250
      data: (term, page) ->
        q: term

      results: (data, page) ->
        results: data.items

      cache: true

    formatResult: itemsFormatResults
    formatSelection: itemsFormatSelection
    escapeMarkup: (m) ->
      m

  $("form.edit_grocery").on "ajax:success", (event, data, status, xhr) ->
    $('#grocery_name').select2('val','')

