$(document).on('ajax:error', 'form', (e, data, status, xhr) => {
  const { responseJSON: errors, responseText: message } = data;
  const toastDuration = 4000;

  if (!errors && message) {
    Materialize.toast(message, toastDuration);
  } else {
    Object.keys(errors).forEach(field => {
      Materialize.toast(`${field}: ${errors[field]}`, toastDuration);
    })
  }
});
