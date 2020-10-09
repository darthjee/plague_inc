(function(_, angular, Cyberhawk) {
  var app = angular.module('simulation/graph_controller', [
    'cyberhawk/notifier'
  ]);

  function Controller(http, timeout, $routeParams, $location) {
    this.http     = http.bind(this);
    this.timeout  = timeout;
    this.id       = $routeParams.id;
    this.location = $location;

    _.bindAll(this, '_summaryPath', '_summaryUrl', '_loadData', '_success', '_enqueueProcess', '_process');
    this._loadData();

    this.mode = "read"
  }

  var fn = Controller.prototype;

  fn._success = function(data) {
    this._setSimulation(data);

    if (this.mode == "read") {
      if (data.instants.length < data.instants_total) {
        this._loadData();
      } else if (data.status != "finished") {
        this._enqueueProcess();
      }
    } else if (this.mode == "process") {
      if (data.status != "finished") {
        this._enqueueProcess();
      }
    }
  };

  fn._setSimulation = function(data) {
    if (this.simulation) {
      data.instants = this.simulation.instants
        .concat(data.instants);

      this.simulation = data;
    } else {
      this.simulation = data;
    }
  };

  fn._loadData = function() {
    this.mode = "read"
    var promisse = this.http.get(this._summaryUrl());

    promisse.success(this._success);
  };

  fn._enqueueProcess = function() {
    this.timeout(this._process, this.simulation.processable_in);
  };

  fn._process = function() {
    this.mode = "process"
    var promisse = this.http.post(this._processingPath(), {});

    promisse.success(this._success);
  };

  fn._processingPath = function() {
    return this.location.$$path + "/contagion/process";
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
    return this.location.$$path + "/contagion/summary";
  };

  app.controller('Simulation.GraphController', [
    "binded_http",
    "$timeout",
    "$routeParams",
    "$location",
    Controller
  ]);
}(window._, window.angular, window.Cyberhawk));
