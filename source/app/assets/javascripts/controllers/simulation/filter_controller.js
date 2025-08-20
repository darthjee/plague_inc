(function(_, angular, Cyberhawk) {
  var app = angular.module("simulation/filter_controller", [
    "cyberhawk/builder"
  ]);

  var Methods = {
    clear: function() {
      this.filters = { tags: [] };
    },
    
    filter: function() {
      console.info(this.location);
    },
  };

  var options = {
    callback: function() {
      _.extend(this, Methods);
      this.clear();
      this.filters = { tags: [] };
      window.debug = this;
    }
  }

  app.controller("Simulation.FilterController", [
    "cyberhawk_builder", function(builder) { builder.build(this, options); }
  ]);
}(window._, window.angular, window.Cyberhawk));