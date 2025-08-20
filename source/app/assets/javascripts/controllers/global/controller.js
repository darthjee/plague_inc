(function(_, angular, Global) {
  var app = angular.module('global/controller', [
    'cyberhawk/notifier',
  ]);

  function Controller(notifier) {
    this.notifier = notifier;
  }

  app.controller('Global.Controller', [
    'cyberhawk_notifier',
    Controller
  ]);

  Global.Controller = Controller;
}(window._, window.angular, window.Global));

