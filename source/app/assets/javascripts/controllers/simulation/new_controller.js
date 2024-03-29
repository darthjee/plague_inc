(function(_, angular, Cyberhawk) {
  var app = angular.module("simulation/new_controller", [
    "simulation/requester",
    "cyberhawk/controller",
    "cyberhawk/notifier",
  ]);

  function Controller(builder, notifier, $location) {
    this.construct(builder.build($location), notifier, $location);
  }

  var fn = Controller.prototype;

  _.extend(fn, Cyberhawk.Controller.prototype);

  fn.payload = function() {
    return {
      simulation: this.data
    };
  };

  fn._goIndex = function() {
    this.location.path(this.location.$$path.replace(/(\w*\/edit|new|\d+\/clone)/, ""));
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
    var references = this.referencesFor(key),
      reference;

    do {
      reference = Math.floor(Math.random() * 1e10);
    } while(_.contains(references, reference));

    return reference;
  };

  fn.referencesFor = function(key) {
    var collection = this.data.settings[key];

    return _.map(collection, function(object) {
      return object.reference;
    });
  };

  fn.removeObject = function(key, index) {
    this.data.settings[key].splice(index, 1);
  };

  fn.addBehavior = function() {
    this.addObject("behaviors");
  };

  fn.removeBehavior = function(index) {
    this.removeObject("behaviors", index);
  };

  fn.addGroup = function() {
    this.addObject("groups");
  };

  fn.removeGroup = function(index) {
    this.removeObject("groups", index);
  };

  app.controller("Simulation.NewController", [
    "simulation_requester", "cyberhawk_notifier", "$location",
    Controller
  ]);
}(window._, window.angular, window.Cyberhawk));

