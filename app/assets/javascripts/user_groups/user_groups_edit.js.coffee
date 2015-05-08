$ ->
  # ============================
  # select2 multiselect
  # ============================

  usersFormatResults = (user) ->
    markup = "<div class=\"row\"><div class=\"columns large-12\"><div>#{user.name}</div></div></div>"

  usersFormatSelection = (user) ->
    if user.state == "invited" || user.state == undefined
      "#{user.name} - invited"
    else
      user.name

  $('.user-groups-edit #user_group_user_ids').select2
    placeholder: "Add other users to the group."
    minimumInputLength: 1
    multiple: true
    ajax:
      url: "/users/auto_complete/?"
      dataType: "json"
      quietMillis: 250
      data: (term, page) ->
        q: term

      results: (data, page) ->
        results: data.users

      cache: true
    initSelection: (element, callback) ->
      $(element).val("")
      callback(users)

    formatResult: usersFormatResults
    formatSelection: usersFormatSelection
    escapeMarkup: (m) ->
      m
