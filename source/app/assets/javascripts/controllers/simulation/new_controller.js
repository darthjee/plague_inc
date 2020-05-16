(function(_, angular, Cyberhawk) {
  var app = angular.module('simulation/new_controller', [
    'cyberhawk/controller',
    'cyberhawk/notifier',
  ]);


  function Controller(builder, notifier, $location) {
    this.construct(builder.build($location), notifier, $location);
  }

  var fn = Controller.prototype;

  _.extend(fn, Cyberhawk.Controller.prototype);

  fn.save = function() {
    var promise = this.requester.saveRequest(this.payload());
    promise.then(this._setData);
    promise.then(this._goIndex);
    promise.error(this._error);
  };

  fn.payload = function() {
    return {
      simulation: this.data
    }
  };

  app.controller('Simulation.NewController', [
    'cyberhawk_requester', 'cyberhawk_notifier', '$location',
    Controller
  ]);
}(window._, window.angular, window.Cyberhawk));

