(function(angular) {
  var module = angular.module('plague_inc');

  module.config(['johtoProvider', function(provider) {
    provider.defaultConfig = {
      controller: 'Global.GenericController',
      controllerAs: 'gnc',
      templateBuilder: function(route) {
        return route + '?ajax=true';
      }
    };

    provider.configs = [{
      routes: ['/'],
      config: {
        controllerAs: 'hc'
      }
    }, {
      routes: ['/admin/users/new', '/admin/users/:id', '/admin/users', '/admin/users/:id/edit']
    }, {
      routes: ['/simulations/new', '/simulations/:id/clone'],
      config: {
        controller: 'Simulation.NewController',
        controllerAs: 'gnc'
      }
    }, {
      routes: ['/simulations/:id', '/simulations']
    }, {
      routes: ['/forbidden']
    }];
    provider.$get().bindRoutes();
  }]);
}(window.angular));

