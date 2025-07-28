(function(_, angular, Cyberhawk) {
  var app = angular.module("tags/controller", [
    "cyberhawk/builder"
  ]);

  var Methods = {
    addTag: function(tags) {
      var tag = this.tag.trim(),
          contains = _.contains(tags, tag);

      if (!(tag === "") && !contains) {
        tags.push(tag);
      }

      this.tag = "";
    },

    removeTag: function(tags, index) {
      tags.splice(index, 1);
    }
  };

  var options = {
    callback: function() {
      _.extend(this, Methods);
      _.bindAll(this, "addTag", "removeTag");
    }
  }

  app.controller("Tags.Controller", [
    "cyberhawk_builder", function(builder) { builder.build(this, options); }
  ]);

  if (!window.Tag) {
    window.Tag = {};
  }

  //window.Tag.Controller = Controller;
}(window._, window.angular, window.Cyberhawk));
