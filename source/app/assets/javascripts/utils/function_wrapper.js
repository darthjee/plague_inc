(function(_) {
  class FunctionWrapper {
    constructor(object, method, wrapper) {
      this.object = object;
      this.method = method;
      this.wrapper = wrapper;
      this.original = object[method];
    }

    wrap(bindArguments) {
      var that = this;
      
      return function() {
        var binded = that._bind(that.original, this, arguments, bindArguments);
        var args = [binded].concat([].slice.call(arguments, 0));

        return that.wrapper.apply(this, args);
      };
    }

    _bind(func, caller, args, bindArguments) {
      if (bindArguments) {
        return function() {
          return func.apply(caller, args);
        };
      } else {
        return _.bind(func, caller);
      }
    }
  }

  _.wrapFunction = function(object, method, wrapper, bindArguments) {
    var wrapper = new FunctionWrapper(object, method, wrapper);

    object[method] = wrapper.wrap(bindArguments);
  };

  _.wrapFunctions = function(object, methods, bindArguments) {
    for (method in methods) {
      var wrapper = methods[method],
        wrapper = new FunctionWrapper(object, method, wrapper);

      object[method] = wrapper.wrap(bindArguments);
    }
  };
})(window._);
