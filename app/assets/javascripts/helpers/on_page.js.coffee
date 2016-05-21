@onPage = (pages, pageJS) ->
  if !Array.isArray(pages)
    pages = [pages]
  for page in pages
    if $('body').hasClass(page)
      pageJS()
