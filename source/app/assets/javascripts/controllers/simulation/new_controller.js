(function(_, angular, Cyberhawk) {
  var app = angular.module('simulation/new_controller', [
    'cyberhawk/builder'
  ]);

  var Methods = {
    payload: function() {
      return {
        simulation: this.data
      };
    },

    addObject: function(key) {
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
    },

    buildReference: function(key) {
      var references = this.referencesFor(key),
        reference;

      do {
        reference = Math.floor(Math.random() * 1e10);
      } while(_.contains(references, reference));

      return reference;
    },

    referencesFor: function(key) {
      var collection = this.data.settings[key];

      return _.map(collection, function(object) {
        return object.reference;
      });
    },

    removeObject: function(key, index) {
      this.data.settings[key].splice(index, 1);
    },

    addBehavior: function() {
      this.addObject('behaviors');
    },

    removeBehavior: function(index) {
      this.removeObject('behaviors', index);
    },

    addGroup: function() {
      this.addObject('groups');
    },

    removeGroup: function(index) {
      this.removeObject('groups', index);
    }
  };

  var options = {
    callback: function() {
      _.extend(this, Methods);
    }
  };

  app.controller('Simulation.NewController', [
    'cyberhawk_builder', function(builder) { builder.buildAndRequest(this, options); }
  ]);
}(window._, window.angular, window.Cyberhawk));

