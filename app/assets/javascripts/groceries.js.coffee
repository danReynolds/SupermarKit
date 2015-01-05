$ ->
  if grocery_id?

    # ============================
    # Table Setup
    # ============================

    $grocery_table = $('#grocery-table').dataTable
      responsive: true
      ajax: "/groceries/" + grocery_id + "/items.json"
      "columnDefs": [
        { "width": "5%", "targets": 6 },
        { "class": "never", "targets": 0 }
      ]

      footerCallback: (row, data, start, end, display) ->
        api = @api()
        
        # Remove the formatting to get integer data for summation
        intVal = (i) ->
          (if typeof i is "string" then i.replace(/[\$,]/g, "") * 1 else (if typeof i is "number" then i else 0))

        if (api.column(3).data().length > 0)
        # Total over all pages
          total = api.column(3).data().reduce((a, b) ->
            intVal(a) + intVal(b)
          )
          
          # Update footer
          $(api.column(5).footer()).html "$" + intVal(total) + " total"
        else
          $(api.column(5).footer()).html "$0 total"

    # ============================
    # Row Removal
    # ============================

    $('.main').on 'click', '.remove', ->
      row = $(@).parents('tr')
      row_id = $grocery_table.fnGetPosition($(@).parents('tr')[0]);
      item_id = $grocery_table.fnGetData(row)[0];
      $.ajax
        method: "PATCH"
        url: "/items/" + item_id + "/remove/?grocery_id=" + grocery_id
        success: ->
          $grocery_table.api().row(row).remove().draw()
