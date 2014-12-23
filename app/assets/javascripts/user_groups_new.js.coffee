$ ->
  # ============================
  # select2 multiselect
  # ============================

  itemsFormatResults = (item) ->
    markup = "<div class=\"row\">" +
    "<div class=\"columns large-12\"><div>" + item.name + "</div></div></div>"

  itemsFormatSelection = (item) ->
    item.name

  $('.user-groups-new #user_group_user_ids').select2
    placeholder: "Add other users to the group."
    minimumInputLength: 1
    multiple: true
    ajax:
      url: "/users/auto_complete"
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