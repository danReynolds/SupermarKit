$ ->
  $('.item_groceries_items_quantity:not(:first-child)').css('display', 'none')

  $('.items-edit #item_groceries_items').change ->
    $(".items-edit .quantity-input").parent().css('display', 'none')
    $(".items-edit #grocery-item-#{@.value}").parent().css('display', 'block')
