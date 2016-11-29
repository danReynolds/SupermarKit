$(document).on('ajax:error', 'form', (e, data, status, xhr) => {
  const { responseJSON: errors } = data;
  Object.keys(errors).forEach(field => {
    Materialize.toast(`${field}: ${errors[field]}`, 4000);
  })
});
