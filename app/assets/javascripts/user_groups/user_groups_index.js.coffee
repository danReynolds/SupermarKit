$ ->
  $('.user-groups-index').on('click', '.default-group:not(.selected)', ->
    _this = this
    $.ajax
      method: "PATCH"
      url: "/users/" + current_user_id + "/default_group/?default_group_id=" + $(this).data('value')
      success: (data) ->
        if ($('.default-group.selected').length > 0)
          $('.default-group.selected')[0].classList.remove('selected')
        $('li.primary-action a').fadeToggle(400, "swing", ->
          $('li.primary-action a').text(data.name + " Kit")
          $('li.primary-action a').fadeIn("slow")
        )
        $('li.primary-action a')[0].href = data.href
        _this.classList.add('selected')
  )
