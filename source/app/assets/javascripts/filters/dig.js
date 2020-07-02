(function(angular) {
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
