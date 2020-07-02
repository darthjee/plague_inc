(function(angular, _) {
  angular
    .module("plague_inc")
    .filter("select_transformer", function() {
      return function(input, mappings, key) {
        return _.find(mappings, function(object) {
          return object[key] === input;
        })
      };
    });
}(window.angular, window._));
