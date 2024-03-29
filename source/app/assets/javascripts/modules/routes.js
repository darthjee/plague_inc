(function(angular) {
  var module = angular.module("plague_inc");

  module.config(["kantoProvider", function(provider) {
    provider.defaultConfig = {
      controller: "Cyberhawk.Controller",
      controllerAs: "gnc",
      templateBuilder(route, params) {
        return route + "?ajax=true";
      }
    };

    provider.configs = [{
      routes: ["/"],
      config: {
        controller: "Home.Controller",
        controllerAs: "hc"
      }
    }, {
      routes: ["/simulations/new", "/simulations/:id/clone"],
      config: {
        controller: "Simulation.NewController",
        controllerAs: "gnc"
      }
    }, {
      routes: ["/simulations/:id", "/simulations"]
    }];
    provider.$get().bindRoutes();
  }]);
}(window.angular));

