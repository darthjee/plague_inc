(function(_, angular, Cyberhawk) {
  var app = angular.module('simulation/new_controller', [
    'cyberhawk/controller',
    'cyberhawk/notifier',
  ]);


  function Controller(builder, notifier, $location) {
    this.construct(builder.build($location), notifier, $location);
  }

  var fn = Controller.prototype;

  _.extend(fn, Cyberhawk.Controller.prototype);

  fn.payload = function() {
    return {
      simulation: this.data
    }
  };

  fn.addGroup = function() {
    if (!this.data.settings) {
      this.data.settings = {
        groups: []
      };
    }
    if (!this.data.settings.groups) {
      this.data.settings.groups = [{}]
    } else {
      this.data.settings.groups.push({});
    }
  };

  app.controller('Simulation.NewController', [
    'cyberhawk_requester', 'cyberhawk_notifier', '$location',
    Controller
  ]);
}(window._, window.angular, window.Cyberhawk));

