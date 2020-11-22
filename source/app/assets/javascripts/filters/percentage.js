(function(angular, _) {
  class Percentage {
    constructor(input) {
      this.input = input;
    }

    toString() {
      if (this.input) {
        return '' + (this.input * 100).toFixed(2) + ' %'
      } else {
        return '0 %';
      }
    }
  }

  Percentage.parse = function(input) {
    return new Percentage(input).toString();
  };

  angular
    .module("plague_inc")
    .filter("percentage", function() {
      return Percentage.parse
    });
}(window.angular, window._));

