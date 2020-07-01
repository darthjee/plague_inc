(function(angular) {
  angular
    .module('plague_inc')
    .filter('select_transformer', function() {
      return function(input, mappings, key, field) {
        return _.find(mappings, function(object) {
          return object[key] == input
        })[field]
      };
    });
}(window.angular));
