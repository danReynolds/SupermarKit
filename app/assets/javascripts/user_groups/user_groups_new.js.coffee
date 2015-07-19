$ ->
  onPage 'user_groups new', ->

    # ============================
    # select2 multiselect
    # ============================

    usersFormatResults = (user) ->
        markup = "<div class=\"row\">" +
        "<div class=\"columns large-12\"><div>" + user.name + "</div></div></div>"

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
            cache: true

          results: (data, page) ->
            results: data.users

        formatResult: usersFormatResults
        formatSelection: (user) ->
          user.name
        escapeMarkup: (m) ->
          m

    # ============================
    # Public / Private Kit switching
    # ============================
    $('#user_group_privacy_public').click ->
        $('p.private').hide();
        $('p.public').show();

    $('#user_group_privacy_private').click ->
        $('p.public').hide();
        $('p.private').show();
