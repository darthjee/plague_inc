(function() {
  [].constructor.prototype.last = function() {
    return this[this.length - 1];
  };
}());
