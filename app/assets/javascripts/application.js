// =============================
// Library Scripts
// =============================

//= require jquery
//= require jquery_ujs
//= require highcharts.min
//= require underscore.min
//= require react
//= require underscore
//= require dropzone
//= require moment
//= require turbolinks
//= require react_ujs
//= require materialize-sprockets

// =============================
// Page Scripts
// =============================

//= require_tree ./mixins
//= require errors
//= require components
//= require_tree ./layouts
//= require_tree ./helpers
//= require_tree ./pages
//= require_tree ./user_groups

document.addEventListener('turbolinks:load', () => Dropzone.autoDiscover = false);
