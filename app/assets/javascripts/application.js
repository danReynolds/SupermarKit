// =============================
// Library Scripts
// =============================

//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require vendor/modernizr
//= require foundation/foundation
//= require foundation/foundation.alert
//= require foundation/foundation.dropdown
//= require foundation/foundation.magellan
//= require foundation/foundation.orbit
//= require foundation/foundation.topbar
//= require foundation/foundation.reveal
//= require foundation/foundation.offcanvas
//= require select2
//= require dataTables/jquery.dataTables
//= require dataTables/jquery.dataTables.foundation
//= require dataTables/extras/dataTables.responsive
//= require turbolinks
//= require highcharts.min
//= require chartkick
//= require nprogress
//= require nprogress-turbolinks
//= require jquery-editable-poshytip.min
//= require jquery.poshytip.min
//= require elevator.min
//= require underscore.min

// =============================
// Page Scripts
// =============================

//= require typeahead
//= require tableFormatter
//= require user_groups/user_groups_show
//= require user_groups/user_groups_new
//= require user_groups/user_groups_edit
//= require user_groups/user_groups_index
//= require user_groups/user_group_metrics
//= require groceries/groceries
//= require items/items
//= require items/items_edit
//= require home
//= require groceries/maps

// =============================

$(function(){
  $(document).foundation({
    "magellan-expedition": {
      active_class: 'active', // specify the class used for active sections
      threshold: 0, // how many pixels until the magellan bar sticks, 0 = auto
      destination_threshold: 20, // pixels from the top of destination for it to be considered active
      throttle_delay: 50, // calculation throttling to increase framerate
      fixed_top: 0, // top distance in pixels assigend to the fixed element on scroll
      offset_by_height: true // whether to offset the destination by the expedition height. Usually you want this to be true, unless your expedition is on the side.
    },
    orbit: {
      animation: 'fade',
      animation_speed: 500,
      navigation_arrows: true,
      bullets: true,
      timer: false,
      variable_height: false
    }
  });
});
