$ ->
  $("#grocery_name").select2
    placeholder: "Search for a repository"
    minimumInputLength: 1
    ajax: # instead of writing the function to execute the request we use Select2's convenient helper
      url: "groceries/2/"
      dataType: "json"
      quietMillis: 250
      data: (term, page) ->
        q: term # search term

      results: (data, page) -> # parse the results into the format expected by Select2.
        # since we are using custom formatting functions we do not need to alter the remote JSON data
        results: data.items

      cache: true

    initSelection: (element, callback) ->
      
      # the input tag has a value attribute preloaded that points to a preselected repository's id
      # this function resolves that id attribute to an object that select2 can render
      # using its formatResult renderer - that way the repository name is shown preselected
      id = $(element).val()
      if id isnt ""
        $.ajax("/groceries/2/auto_complete"
          dataType: "json"
        ).done (data) ->
          callback data
          return

      return

    formatResult: repoFormatResult # omitted for brevity, see the source of this page
    formatSelection: repoFormatSelection # omitted for brevity, see the source of this page
    dropdownCssClass: "bigdrop" # apply css that makes the dropdown taller
    escapeMarkup: (m) -> # we do not want to escape markup since we are displaying html in results
      m

  repoFormatResult = (repo) ->
    markup = "<div class=\"row-fluid\">" + "<div class=\"span2\"><img src=\"" + repo.owner.avatar_url + "\" /></div>" + "<div class=\"span10\">" + "<div class=\"row-fluid\">" + "<div class=\"span6\">" + repo.full_name + "</div>" + "<div class=\"span3\"><i class=\"fa fa-code-fork\"></i> " + repo.forks_count + "</div>" + "<div class=\"span3\"><i class=\"fa fa-star\"></i> " + repo.stargazers_count + "</div>" + "</div>"
    markup += "<div>" + repo.description + "</div>"  if repo.description
    markup += "</div></div>"
    markup
  repoFormatSelection = (repo) ->
    repo.full_name

