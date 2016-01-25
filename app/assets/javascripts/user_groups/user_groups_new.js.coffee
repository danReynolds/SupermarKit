$ ->
  onPage 'user_groups new', ->

    # ============================
    # Public / Private Kit switching
    # ============================
    $('#user_group_privacy_public').click ->
        $('p.private').addClass('hide');
        $('p.public').removeClass('hide');

    $('#user_group_privacy_private').click ->
        $('p.public').addClass('hide')
        $('p.private').removeClass('hide');

    # ============================
    # Form Submission
    # - because simpleform changes the DOM,
    # - it messes up the React VD, need to not put React
    # - component within simpleform
    # ============================
    $('.submit-group-form').click ->
      $('.simple_form.new_user_group').submit()

    # ============================
    # The activator needs to prevent default so the
    # anchor isn't triggered
    $('.activator').click (e) ->
      e.preventDefault()
