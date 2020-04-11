(function(_) {
  class Delegator {
    constructor(caller, objectName) {
      this.caller = caller;
      this.objectName = objectName;
      _.bindAll(this, 'delegate');
    }

    delegate(method) {
      var objectName = this.objectName;

      this.caller.prototype[method] = function() {
        var object = this[objectName]
        return object[method].apply(object, arguments);
      };
    };
  }

  _.delegate = function(caller, object) {
    var methods = [].slice.call(arguments, 2),
      delegator = new Delegator(caller, object);

    _.each(methods, delegator.delegate);
  }
})(window._);
