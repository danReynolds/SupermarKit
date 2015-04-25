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
      ajax:
        url: "/user_groups/" + user_group_id + "/groceries.json"
        dataSrc: (json) ->
          json = formatGroceries(json)

      "order": [[ 0, "asc" ]]
      "columnDefs": [
        { "class": "never", "targets": 0 }
        { "class": "min-tablet-l", "targets": 2 }
        { "class": "min-tablet-l", "targets": 3 }
        { "class": "min-tablet-p", "targets": 4 }
      ]