(function(_, angular, Cyberhawk) {
  var module = angular.module("simulation/requester", ["binded_http"]);

  class SimulationRequesterService extends Cyberhawk.RequesterService {
  }

  function SimulationRequesterServiceBuilder($http) {
    this.http = $http;
  }

  SimulationRequesterServiceBuilder.prototype.build = function($location) {
    var path = $location.$$path + ".json";
    var savePath = $location.$$path.replace(/\/(new|edit)$/, "") + ".json";
    return new SimulationRequesterService(path, savePath, this.http);
  };

  function SimulationRequesterServiceFactory($http) {
    return new SimulationRequesterServiceBuilder($http);
  }

  module.service("simulation_requester", [
    "binded_http",
    SimulationRequesterServiceFactory
  ]);

}(window._, window.angular, window.Cyberhawk));
