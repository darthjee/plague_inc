(function(_, angular) {
  var module = angular.module("simulation/process", [
    "binded_http"
  ]);

  class Processor {
    constructor(http, $location) {
      this.http     = http;
      this.location = $location;

      _.bindAll(this, "_success");
    }

    bind(controller) {
      this.controller = controller;
      this.http.bind(controller);

      return this;
    }

    process() {
      return this._addHandlers(
        this.http.post(this._processingPath(), {})
      );
    }

    read() {
      return this._addHandlers(
        this.http.get(this._summaryUrl())
      );
    }

    _addHandlers(promisse) {
      return promisse.success(this._success);
    }

    _success(data) {
      var newInstant = this._findLastInstant(data.instants);

      if (newInstant) {
        this.lastInstant = newInstant;
      }
    }

    _processingPath() {
      return this.location.$$path + "/contagion/process";
    }

    _summaryUrl() {
      var path = this._summaryPath();

      var lastInstant = this.lastInstant;
      if (lastInstant) {
        return path + "?pagination[last_instant_id]="+lastInstant.id;
      } else {
        return path;
      }
    }

    _summaryPath() {
      return this.location.$$path + "/contagion/summary";
    }

    _findLastInstant(instants) {
      for (var index = instants.length - 1; index >= 0; index--) {
        var instant = instants[index];

        if (instant.status === "processed") {
          return instant;
        }
      }
    }
  }

  var ProcessorServiceFactory = function(http, $location) {
    return new Processor(http, $location);
  };

  module.service("simulation_processor", [
    "binded_http",
    "$location",
    ProcessorServiceFactory
  ]);
}(window._, window.angular, window.Cyberhawk));
