(function(_, angular, Cyberhawk) {
  var app = angular.module('simulation/new_controller', [
    'simulation/requester',
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

  fn.addObject = function(key) {
    if (!this.data.settings) {
      this.data.settings = {
        behaviors: [],
        groups: []
      };
    }
    if (!this.data.settings[key]) {
      this.data.settings[key] = [];
    }

    this.data.settings[key].push({
      reference: this.buildReference(key)
    });
  };

  fn.buildReference = function(key) {
    var collection = this.data.settings[key];

    while(true) {
      var reference = Math.floor(Math.random() * 1e10);

      var other = _.find(collection, function(object) {
        return  object.reference === reference;
      });

      if (! other) {
        return reference;
      }
    }
  }

  fn.removeObject = function(key, index) {
    this.data.settings[key].splice(index, 1);
  };

  fn.addBehavior = function() {
    this.addObject('behaviors');
  };

  fn.removeBehavior = function(index) {
    this.removeObject('behaviors', index);
  };

  fn.addGroup = function() {
    this.addObject('groups');
  };

  fn.removeGroup = function(index) {
    this.removeObject('groups', index);
  };

  app.controller('Simulation.NewController', [
    'simulation_requester', 'cyberhawk_notifier', '$location',
    Controller
  ]);
}(window._, window.angular, window.Cyberhawk));

