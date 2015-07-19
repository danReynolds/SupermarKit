$ ->
  onPage 'items new', ->
    $('#new_item #price').change ->
      $('.hidden #item_price').val($(@).val())
