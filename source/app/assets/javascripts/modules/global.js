(function(angular) {
  window.Global = {};

  angular.module("global", [
    "global/controller",
    "global/header_controller",
    "global/generic_controller",
    "tags/controller"
  ])
}(window.angular));
