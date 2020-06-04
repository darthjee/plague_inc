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

  fn.addBehavior = function() {
    if (!this.data.settings) {
      this.data.settings = {
        behaviors: []
      };
    }
    if (!this.data.settings.behaviors) {
      this.data.settings.behaviors = [{}]
    } else {
      this.data.settings.behaviors.push({});
    }
  };

  fn.removeBehavior = function(index) {
    this.data.settings.behaviors.splice(index, 1);
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

  fn.removeGroup = function(index) {
    this.data.settings.groups.splice(index, 1);
  };

  app.controller('Simulation.NewController', [
    'cyberhawk_requester', 'cyberhawk_notifier', '$location',
    Controller
  ]);
}(window._, window.angular, window.Cyberhawk));

