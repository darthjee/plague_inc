(function(_, angular, Cyberhawk) {
  var app = angular.module("home/controller", [
    "cyberhawk/controller",
    "cyberhawk/notifier",
  ]);


  function Controller(builder, notifier, $location) {
    this.construct(builder.build($location), notifier, $location);
  }

  var fn = Controller.prototype;

  _.extend(fn, Cyberhawk.Controller.prototype);

  app.controller("Home.Controller", [
    "cyberhawk_requester", "cyberhawk_notifier", "$location",
    Controller
  ]);

  Home.Controller = Controller;
}(window._, window.angular, window.Cyberhawk));
