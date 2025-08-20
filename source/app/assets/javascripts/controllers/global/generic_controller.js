(function(_, angular) {
  var app = angular.module('global/generic_controller', [
    'cyberhawk/builder'
  ]);

  var LoginMethods = {
    login: function() {
      this.logged = true;
    },
    logoff: function() {
      this.logged = false;
    }
  };

  var options = {
    callback: function(){
      _.extend(this, LoginMethods);
      _.bindAll(this, 'login', 'logoff');

      this.notifier.register('login-success', this.login);
      this.notifier.register('logged', this.login);
      this.notifier.register('logoff-success', this.logoff);
    }
  };

  app.controller('Global.GenericController', [
    'cyberhawk_builder', function(builder) {
      builder.buildAndRequest(this, options);

    }
  ]);
}(window._, window.angular));  
