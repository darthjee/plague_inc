(function(_, angular, Cyberhawk) {
  var app = angular.module('simulation/graph_controller', [
    'cyberhawk/notifier'
  ]);

  function Controller(notifier) {
    console.info(arguments);
    this.notifier = notifier;

    _.bindAll(this, '_setSimulation');

    notifier.register('simulation', this._setSimulation);
  }

  var fn = Controller.prototype;

  fn._setSimulation = function(data) {
    console.info('data', data);
    console.info(arguments);
  };

  app.controller('Simulation.GraphController', [
    'cyberhawk_notifier',
    Controller
  ]);
}(window._, window.angular, window.Cyberhawk));
