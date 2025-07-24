(function(_, angular, Cyberhawk) {
  var module = angular.module("simulation/requester", ["binded_http"]);

  class SimulationRequesterService extends Cyberhawk.RequesterService {
    saveRequest(data) {
      return this.http.post(this.savePath, data);
    }
  }

  class SimulationRequesterServiceBuilder {
    constructor ($http) {
      this.http = $http;
    }

    build($location) {
      var path = $location.$$path + ".json";
      var savePath = $location.$$path.replace(/\/(new|edit|\d+\/clone)$/, "") + ".json";
      return new SimulationRequesterService(path, savePath, this.http);
    }
  }

  function SimulationRequesterServiceFactory($http) {
    return new SimulationRequesterServiceBuilder($http);
  }

  module.service("simulation_requester", [
    "binded_http",
    SimulationRequesterServiceFactory
  ]);

}(window._, window.angular, window.Cyberhawk));
