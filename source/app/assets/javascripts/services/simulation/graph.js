(function(_, angular) {
  var module = angular.module("simulation/graph", []);

  class Graph {
  }

  function GraphServiceFactory() {
    return new Graph();
  };

  module.service("simulation_processor", [
    GraphServiceFactory
  ]);
}(window._, window.angular));

