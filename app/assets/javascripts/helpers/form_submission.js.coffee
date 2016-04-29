@setupFormSubmission = (submissionElement, submissionForm) ->
  # ============================
  # Form Submission
  # - because simpleform changes the DOM,
  # - it messes up the React VD, need to not put React
  # - component within simpleform
  # ============================
  $(submissionElement).click ->
    $(submissionForm).submit()
