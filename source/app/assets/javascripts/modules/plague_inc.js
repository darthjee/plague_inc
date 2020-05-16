(function(angular) {
  var module = angular.module('plague_inc', [
    'global',
    'cyberhawk',
    'kanto',
    'home',
    'simulation'
  ]);

  module.config(['$httpProvider', function($httpProvider) {
    $httpProvider.defaults.headers.patch = {
      'Content-Type': 'application/json;charset=utf-8'
    };
  }]);
}(window.angular));
