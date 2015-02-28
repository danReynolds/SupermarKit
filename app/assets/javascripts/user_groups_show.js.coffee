$ ->
  if active_grocery_id? && user_group_id?

    # ============================
    # select2 multiselect
    # ============================

    itemsFormatResults = (item) ->
      if not item.description
        item.description = ""
      else if item.description.length > 0
        item.description = " - " + item.description
      if item.description.length > 20
        item.description = item.description.substr(0,20) + "..."

      markup = "<div class=\"row\">" +
      "<div class=\"columns large-2\"><i class=\"fa fa-shopping-cart\"></i></div>" +
      "<div class=\"columns large-10\"><div class=\"row\"><div>" + item.name + item.description + "</div></div></div>"


    itemsFormatSelection = (item) ->
      item.name

    $('.user-groups-show #items_ids').select2
      placeholder: "Add grocery items."
      minimumInputLength: 1
      multiple: true
      closeOnSelect: false
      ajax:
        url: "/groceries/" + active_grocery_id + "/items/auto_complete.json"
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

      createSearchChoice: (term, data) ->
          if data.length == 0
            {
              id: $.trim(term),
              name: $.trim(term)
              description: 'Add new item'
            }

    $("form.items").on "ajax:success", (event, data, status, xhr) ->
      $('#s2id_items_ids').select2('val','')
      $groceries_table.ajax.reload()
      $active_grocery_table.ajax.reload()

    # ============================
    # Widget Tables Setup
    # ============================

    $groceries_table = $('#groceries-table').DataTable
      responsive: true
      searching: false
      bLengthChange: false
      iDisplayLength: 5,
      ajax: "/user_groups/" + user_group_id + "/groceries.json"
      "order": [[ 5, "asc" ]]
      "columnDefs": [
        { "class": "never", "targets": 0 }
      ]

    $active_grocery_table = $('#active-grocery-table').DataTable
      responsive: true
      searching: false
      bLengthChange: false
      iDisplayLength: 5,
      ajax: "/groceries/" + active_grocery_id + "/items.json"
      "columnDefs": [
        { "class": "never", "targets": 0 }
      ]
      footerCallback: (row, data, start, end, display) ->
        api = @api()

        # Remove the formatting to get integer data for summation
        intVal = (i) ->
          (if typeof i is "string" then i.replace(/[\$,]/g, "") * 1 else (if typeof i is "number" then i else 0))

        if (api.column(4).data().length > 0)
        # Total over all pages
          total = api.column(4).data().reduce((a, b) ->
            intVal(a) + intVal(b)
          )

          # Update footer
          $(api.column(4).footer()).html "$" + intVal(total).toFixed(2) + " total"
        else
          $(api.column(4).footer()).html "$0 total"
