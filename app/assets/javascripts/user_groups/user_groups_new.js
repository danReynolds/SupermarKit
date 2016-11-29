document.addEventListener('turbolinks:load', () => {
  onPage(['user_groups new'], () => {
    // ============================
    // Public / Private Kit switching
    // ============================
    $('#user_group_privacy_public').click(() => {
      $('p.private').addClass('hide');
      $('p.public').removeClass('hide');
    });

    $('#user_group_privacy_private').click(() => {
      $('p.public').addClass('hide');
      $('p.private').removeClass('hide');
    });

    setupFormSubmission('.submit-group-form', '.simple_form.new_user_group');
  });
});
