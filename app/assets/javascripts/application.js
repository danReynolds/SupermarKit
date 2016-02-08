// =============================
// Library Scripts
// =============================

//= require jquery
//= require jquery_ujs
//= require highcharts.min
//= require chartkick
//= require elevator.min
//= require underscore.min
//= require materialize-sprockets
//= require react
//= require react_ujs

// =============================
// Page Scripts
// =============================

//= require components
//= require_tree ./layouts
//= require_tree ./helpers
//= require_tree ./pages
//= require_tree ./user_groups
//= require_tree ./groceries
//= require_tree ./items

$(document).ready(function() {
    $('.collapsible').collapsible({
        accordion : false
    });
});
