(function(_, angular) {
  var module = angular.module("simulation/process", [
    "binded_http"
  ]);

  class Processor {
    constructor(http, $location) {
      this.http     = http;
      this.location = $location;
    }

    bind(controller) {
      this.controller = controller;
      this.http.bind(controller);

      return this;
    }

    process = function() {
      return this.http.post(this._processingPath(), {});
    }

    read() {
      return this.http.get(this._summaryUrl());
    }

    _processingPath() {
      return this.location.$$path + "/contagion/process";
    }

    _summaryUrl() {
      var path = this._summaryPath();

      var lastInstant = this._lastInstant();
      if (lastInstant) {
        return path + "?pagination[last_instant_id]="+lastInstant.id;
      } else {
        return path;
      }
    }

    _summaryPath() {
      return this.location.$$path + "/contagion/summary";
    }

    _lastInstant() {
      var simulation = this.controller.simulation;

      if (simulation && simulation.instants.length > 0) {
        var instants = simulation.instants;

        for (var index = instants.length - 1; index >= 0; index--) {
          var instant = instants[index];

          if (instant.status === "processed") {
            return instant;
          }
        }
      }
    }
  }

  ProcessorServiceFactory = function(http, $location) {
    return new Processor(http, $location);
  };

  module.service("simulation_processor", [
    "binded_http",
    "$location",
    ProcessorServiceFactory
  ]);
}(window._, window.angular, window.Cyberhawk));
