$ ->
  onPage 'user_groups metrics', ->
    $('#graph-tabs').on 'toggled', ->
      $(window).trigger('resize')
