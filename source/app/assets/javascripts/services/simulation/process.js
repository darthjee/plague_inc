(function(_, angular) {
  var module = angular.module("simulation/process", []);

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

    _processingPath() {
      return this.location.$$path + "/contagion/process";
    };
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
