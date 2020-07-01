(function(angular) {
  angular
    .module('plague_inc')
    .filter('select_transformer', function() {
      return function(input, mappings, key) {
        return _.find(mappings, function(object) {
          return object[key] == input
        })
      };
    });

  angular
    .module('plague_inc')
    .filter('dig', function() {
      return function(input, keys) {
        return _.reduce(keys.split('.'), function(result, key) {
          return result[key];
        }, input)
      };
    });
}(window.angular));
