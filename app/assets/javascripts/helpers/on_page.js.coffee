@onPage = (page, pageJS) ->
  if $('body').hasClass(page)
    pageJS()
