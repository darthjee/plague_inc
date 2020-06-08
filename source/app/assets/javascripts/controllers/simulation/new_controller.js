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

  fn.addObject = function(key) {
   if (!this.data.settings) {
      this.data.settings = {
        behaviors: []
      };
   }
    if (!this.data.settings[key]) {
      this.data.settings[key] = [{}];
    } else {
      this.data.settings[key].push({});
    }
  };

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
    'cyberhawk_requester', 'cyberhawk_notifier', '$location',
    Controller
  ]);
}(window._, window.angular, window.Cyberhawk));

