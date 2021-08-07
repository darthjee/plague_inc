(function(_, angular, Cyberhawk) {
  var app = angular.module('tags/controller', [
    'cyberhawk/controller',
    'cyberhawk/notifier',
  ]);

  function Controller(builder, notifier, $location) {
    this.construct(builder.build($location), notifier, $location);
  }

  var fn = Controller.prototype;

  _.extend(fn, Cyberhawk.Controller.prototype);

  app.controller('Tags.Controller', [
    'cyberhawk_requester', 'cyberhawk_notifier', '$location',
    Controller
  ]);

  fn.addTag = function(tags) {
    var tag = this.tag.trim(),
        contains = _.contains(tags, tag);

    if (!(tag == '') && !contains) {
      tags.push(tag);
    }

    this.tag = '';
  };

  if (!window.Tag) {
    window.Tag = {};
  }

  Tag.Controller = Controller;
}(window._, window.angular, window.Cyberhawk));
