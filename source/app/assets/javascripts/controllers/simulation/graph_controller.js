(function(_, angular, Cyberhawk) {
  var app = angular.module('simulation/graph_controller', [
    'cyberhawk/notifier'
  ]);

  function Controller(http, $routeParams, $location) {
    this.http     = http.bind(this);
    this.id       = $routeParams.id;
    this.location = $location;

    this._loadData();
  }

  var fn = Controller.prototype;

  fn._setSimulation = function(data) {
    if (this.simulation) {
    } else {
      console.info(data)
      this.simulation = data;
    }
  };

  fn._loadData = function() {
    var promisse = this.http.get(this.sumaryPath());

    promisse.success(this._setSimulation);
  };

  fn.sumaryPath = function() {
    return this.location.$$path + "/contagion/summary"
  };

  app.controller('Simulation.GraphController', [
    "binded_http",
    "$routeParams",
    "$location",
    Controller
  ]);
}(window._, window.angular, window.Cyberhawk));
