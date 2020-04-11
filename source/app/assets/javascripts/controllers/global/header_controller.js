(function(_, angular, Global) {
  var app = angular.module('global/header_controller', [
    'cyberhawk/notifier',
    'binded_http'
  ]);

  function Controller(http, notifier) {
    this.http = http.bind(this);
    this.notifier = notifier;
  }

  var fn = Controller.prototype;

  app.controller('Global.HeaderController', [
    'binded_http', 'cyberhawk_notifier',
    Controller
  ]);

  Global.Controller = Controller;
}(window._, window.angular, window.Global));


