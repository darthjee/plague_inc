(function(_, angular, Cyberhawk) {
  var app = angular.module("simulation/filter_controller", [
    "cyberhawk/builder"
  ]);

  var Methods = {
    load: function(){
      this.filters = {};
      var search = this.location.search();
      this.filters.name = search['filter[name]'];
      this.filters.tags = search['filter[tag_name][]'] || [];
      console.info(this.location.search());
    },

    clear: function() {
      this.filters = { tags: [] };
    },
    
    filter: function() {
      this.location.search(this._filterQuery())
    },

    _filterQuery: function() {
      var query = {};
    
      if (this.filters.name) {
        query['filter[name]'] = this.filters.name;
      }
      
      if (this.filters.tags) {
        query['filter[tag_name][]'] = this.filters.tags;
      }
      return query;
    }
  };

  var options = {
    callback: function() {
      _.extend(this, Methods);
      this.load();
    }
  }

  app.controller("Simulation.FilterController", [
    "cyberhawk_builder", function(builder) { builder.build(this, options); }
  ]);
}(window._, window.angular, window.Cyberhawk));