(function(_, angular, Cyberhawk) {
  var app = angular.module('simulation/show_controller', [
    'cyberhawk/notifier'
  ]);

  function Controller(notifier) {
    console.info(arguments);
    this.notifier = notifier;
  }

  var fn = Controller.prototype;

  app.controller('Simulation.ShowController', [
    'cyberhawk_notifier',
    Controller
  ]);
}(window._, window.angular, window.Cyberhawk));


