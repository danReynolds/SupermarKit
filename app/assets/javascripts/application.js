// =============================
// Library Scripts
// =============================

//= require jquery
//= require jquery_ujs
//= require highcharts.min
//= require underscore.min
//= require materialize-sprockets
//= require react
//= require underscore
//= require react_ujs
//= require dropzone
//= require moment

// =============================
// Page Scripts
// =============================

//= require_tree ./mixins
//= require components
//= require_tree ./layouts
//= require_tree ./helpers
//= require_tree ./pages
//= require_tree ./user_groups
//= require_tree ./groceries

$(document).ready(function() {
    Dropzone.autoDiscover = false;
});
