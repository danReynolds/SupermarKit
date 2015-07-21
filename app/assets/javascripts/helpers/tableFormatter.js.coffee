@formatItems = (json) ->
  dataRows = []

  $.each json.data, (i, item) ->
    dataRow = [
      item.id,
      "<a href='#' id='well' class='editable' name='name' data-type='text' data-pk='{ item_id: #{item.id} }' data-url='#{item.path}'>#{item.name}</a>",
      "<a href='#' class='editable' name='description' data-type='text' data-pk='{ item_id: #{item.id} }' data-url='#{item.path}'>#{item.description}</a>",
      "<a href='#' class='editable' name='groceries_items_quantity' data-type='text' data-pk='{ item_id: #{item.id}, groceries_items_id: #{item.grocery_item_id } }' data-url='#{item.path}'>#{item.quantity}</a>",
      "<a href='#' class='editable' name='groceries_items_price' data-value='#{item.price}' data-type='text' data-pk='{ item_id: #{item.id}, groceries_items_id: #{item.grocery_item_id } }' data-url='#{item.path}'>#{item.price_formatted}</a>",
      item.total_price_formatted,
      "<a class='remove' href='#'><i class='icon ion-close-circled'></i></a>"
    ]
    dataRows.push(dataRow)

  return dataRows

@formatGroceries = (json) ->
  dataRows = []

  $.each json.data, (i, grocery) ->
    finishedData = ""
    finishedData = '<i class="fa fa-check"</i>' if grocery.finished

    dataRow = [
      grocery.id,
      "<a href='/groceries/#{grocery.id}'>#{grocery.name}</a>",
      grocery.description,
      grocery.count,
      grocery.cost,
      finishedData
    ]
    dataRows.push(dataRow)

  return dataRows

@formatCarryOver = (json) ->
  dataRows = []

  $.each json.data, (i, item) ->
    dataRow = [
      "<div class='item' value=#{item.id}>#{item.name}<i class='remove fa fa-remove'></div>"
    ]
    dataRows.push(dataRow)

  return dataRows
