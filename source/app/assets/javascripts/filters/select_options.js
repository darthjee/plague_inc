(function(angular, _) {
  class Finder {
    constructor(input, mappings, key) {
      this.input = input;
      this.mappings = mappings;
      this.key = key;
    }

    find() {
      var input = this.input,
          key = this.key;

      if (input === null) {
        return null;
      }

      return _.find(this.mappings, function(object) {
        return object[key] === input;
      });
    }
  }

  Finder.find = function(input, mappings, key) {
    return new Finder(input, mappings, key).find();
  };

  angular
    .module("plague_inc")
    .filter("select_transformer", function() {
      return Finder.find;
    });
}(window.angular, window._));
