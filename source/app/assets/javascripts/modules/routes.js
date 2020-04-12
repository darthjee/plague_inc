(function(angular) {
  var module = angular.module('plague_inc');

  module.config(['kantoProvider', function(provider) {
    provider.defaultConfig = {
      controller: 'Cyberhawk.Controller',
      controllerAs: 'gnc',
      templateBuilder: function(route, params) {
        return route + '?ajax=true';
      }
    }

    provider.configs = [{
      routes: ['/'],
      config: {
        controller: 'Home.Controller',
        controllerAs: 'hc'
      }
    }];
    provider.$get().bindRoutes();
  }]);
}(window.angular));

