# $ ->
#   setValue = ($e, data) ->
#     $('#item_id').val(data.id)

#   $("#item_name").typeahead(
#     name: "book"
#     displayKey: 'value'
#     hightlight: true
#     remote: "/items/auto_complete?query=%QUERY"
#   ).on("typeahead:selected", setValue).on("typeahead:autocompleted", setValue)
