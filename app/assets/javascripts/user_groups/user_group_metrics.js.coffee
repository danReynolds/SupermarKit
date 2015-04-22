$ ->
  $('#graph-tabs').on 'toggled', ->
    $(window).trigger('resize')