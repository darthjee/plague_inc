(function(_, angular, Cyberhawk) {
  var app = angular.module('simulation/graph_controller', [
    'cyberhawk/notifier'
  ]);

  function Controller(http, $routeParams, $location) {
    this.http     = http.bind(this);
    this.id       = $routeParams.id;
    this.location = $location;

    _.bindAll(this, '_summaryPath', '_summaryUrl', '_loadData', '_setSimulation');
    this._loadData();
  }

  var fn = Controller.prototype;

  fn._setSimulation = function(data) {
    if (this.simulation) {
      data.instants = this.simulation.instants
        .concat(data.instants);

      this.simulation = data;
    } else {
      this.simulation = data;
    }

    if (data.instants.length < data.instants_total) {
      this._loadData();
    }
  };

  fn._loadData = function() {
    var promisse = this.http.get(this._summaryUrl());

    promisse.success(this._setSimulation);
  };

  fn._summaryUrl = function() {
    var path = this._summaryPath();

    if (this.simulation && this.simulation.instants.length > 0) {
      var lastInstanId = this.simulation.instants.slice(-1).pop().id

      return path + "?pagination[last_instant_id]="+lastInstanId;
    } else {
      return path;
    }
  };

  fn._summaryPath = function() {
    return this.location.$$path + "/contagion/summary"
  };

  app.controller('Simulation.GraphController', [
    "binded_http",
    "$routeParams",
    "$location",
    Controller
  ]);
}(window._, window.angular, window.Cyberhawk));
