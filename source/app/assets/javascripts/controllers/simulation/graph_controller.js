(function(_, angular, Cyberhawk) {
  var app = angular.module("simulation/graph_controller", [
    "cyberhawk/notifier",
    "simulation/process",
    "simulation/graph"
  ]);

  function Controller(timeout, $routeParams, processor, graph) {
    this.timeout   = timeout;
    this.id        = $routeParams.id;
    this.processor = processor.bind(this);
    this.graph     = graph

    _.bindAll(
      this, "_loadData", "_success", "_error", "_enqueueProcess", "_process"
    );
    this._loadData();

    this.mode = "read";
    this.process = false;
    window.debug = graph;
  }

  var fn = Controller.prototype;

  fn._success = function(data) {
    this._setSimulation(data);
    this._drawGraph();
    this._updateMode();

    if (this.mode === "read") {
      this._loadData();
    } else if (this.process && this.mode === "process") {
      this._enqueueProcess();
    }
  };

  fn._error = function(_, code) {
    this.timeout(this._loadData, 120000);
  };

  fn.pause = function() {
    this._triggerLoadData(false);
  };

  fn.unpause = function() {
    this._triggerLoadData(true);
  };

  fn._triggerLoadData = function(processing) {
    this.process = processing;

    if (!this.ongoing) {
      this._loadData();
    }
  };

  fn._updateMode = function() {
    if (this.simulation.instants.length >= this.simulation.instants_total) {
      if (this.simulation.status === "finished") {
        this.mode = "finished";
      } else {
        this.mode = "process";
      }
    }
  };

  fn._setSimulation = function(data) {
    if (this.simulation) {
      var instants = this._processedInstants();

      data.instants = instants.concat(data.instants);
    }

    this.simulation = data;
  };

  fn._processedInstants = function() {
    return _.select(this.simulation.instants, function(instant) {
      return instant.status === "processed";
    });
  };

  fn._loadData = function() {
    var promisse = this.processor.read();

    this._handlePromisse(promisse);
  };

  fn._enqueueProcess = function() {
    this.timeout(this._process, this.simulation.processable_in * 1000 + 50);
  };

  fn._process = function() {
    this.mode = "process";

    var promisse = this.processor.process();

    this._handlePromisse(promisse);
  };

  fn._handlePromisse = function(promisse) {
    promisse
      .success(this._success)
      .error(this._error);
  };

  fn._drawGraph = function() {
    this.graph.draw(this.simulation.instants);
  };

  app.controller("Simulation.GraphController", [
    "$timeout",
    "$routeParams",
    "simulation_processor",
    "simulation_graph",
    Controller
  ]);
}(window._, window.angular, window.Cyberhawk));
