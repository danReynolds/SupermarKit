@setup_typeahead = ($select2, $table, $form, grocery_id) ->
  # ============================
  # select2 multiselect
  # ============================

  itemsFormatResults = (item) ->
    if not item.description
      item.description = ''
    else if item.description.length > 0
      item.description = ' - ' + item.description
    if item.description.length > 20
      item.description = item.description.substr(0,20) + '...'

    markup = '<div class=\'row\'>' +
    '<div class=\'columns large-2\'><i class=\'fa fa-shopping-cart\'></i></div>' +
    '<div class=\'columns large-10\'><div class=\'row\'><div>' + item.name + item.description + '</div></div></div>'


  itemsFormatSelection = (item) ->
    item.name

  $select2.select2
    placeholder: 'Add grocery items.'
    minimumInputLength: 1
    multiple: true
    closeOnSelect: false
    ajax:
      url: "/groceries/#{grocery_id}/items/auto_complete.json"
      dataType: 'json'
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

    createSearchChoice: (term, data) ->
        if data.length == 0
          {
            id: $.trim(term),
            name: $.trim(term)
            description: 'Add new item'
          }

  $form.on 'ajax:success', (event, data, status, xhr) ->
    $('#s2id_items_ids').select2('val','')
    $table.api().ajax.reload(null, false)
