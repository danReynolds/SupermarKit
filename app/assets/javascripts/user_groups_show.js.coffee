$ ->
  if active_grocery_id? && user_group_id?

    # ============================
    # Widget tables setup
    # ============================

    $groceries_table = $('#groceries-table').dataTable
      responsive: true
      searching: false
      bLengthChange: false
      iDisplayLength: 5,
      ajax: "/user_groups/" + user_group_id + "/groceries.json"
      "order": [[ 5, "asc" ]]
      "columnDefs": [
        { "class": "never", "targets": 0 }
        { "class": "min-tablet-l", "targets": 2 }
        { "class": "min-tablet-l", "targets": 3 }
        { "class": "min-tablet-p", "targets": 4 }
      ]

    $active_grocery_table = $('#active-grocery-table').dataTable
      responsive: true
      searching: false
      bLengthChange: false
      iDisplayLength: 5,
      ajax: "/groceries/" + active_grocery_id + "/items.json"
      "columnDefs": [
        { "class": "never", "targets": 0 },
        { "class": "min-tablet-l", "targets": 2 }
        { "class": "min-tablet-p", "targets": 3 }
        { "class": "min-tablet-p", "targets": 4 }
      ]

      footerCallback: (row, data, start, end, display) ->
        api = @api()

        # Remove the formatting to get integer data for summation
        intVal = (i) ->
          (if typeof i is "string" then i.replace(/[\$,]/g, "") * 1 else (if typeof i is "number" then i else 0))

        if (api.column(5).data().length > 0)
        # Total over all pages
          total = api.column(5).data().reduce((a, b) ->
            intVal(a) + intVal(b)
          )

          # Update footer
          $(api.column(5).footer()).html "$" + intVal(total).toFixed(2) + " total"
        else
          $(api.column(5).footer()).html "$0 total"

      createdRow: (row, data, index) ->
        $.fn.editable.defaults.mode = 'popup'
        $.fn.editable.defaults.ajaxOptions = { type: "PATCH" };

        $(row).find('.editable').editable
          placement: 'bottom'
          emptytext: 'Add...'
          highlight: '#5AF2AC'

          success: ->
            $active_grocery_table.api().ajax.reload(null, false)

          params: (params) ->
              params.item = { id: params.pk.item_id, }

              if (this.name == "groceries_items_attributes")
                params.item.groceries_items_attributes = {
                  "0": { 
                    "quantity": params.value,
                    id: params.pk.groceries_items_id
                  }
                }
              else
                params.item[this.name] = params.value

              return params;

    $active_grocery_table.on 'click', 'tr td:first-child:not(.child)', ->
      $(this).parents('tbody').find('.child a').editable
        placement: 'bottom'
        emptytext: 'Add...'
        highlight: '#5AF2AC'

        success: ->
            $active_grocery_table.api().ajax.reload(null, false)

          params: (params) ->
              params.item = { id: params.pk.item_id, }

              if (this.name == "groceries_items_attributes")
                params.item.groceries_items_attributes = {
                  "0": { 
                    "quantity": params.value,
                    id: params.pk.groceries_items_id
                  }
                }
              else
                params.item[this.name] = params.value

              return params;

    # ============================
    # Typeahead setup
    # ============================

    setup_typeahead($('.user-groups-show #items_ids'), $active_grocery_table, $("form.items"), active_grocery_id)