(function() {
  'use strict';
  angular.module('kb.accordion', ['template/accordion/accordion-group.html']).run([
    '$templateCache', function($templateCache) {
      return $templateCache.put("template/accordion/accordion-group.html", "<div class=\"panel panel-default\">\n<div class=\"panel-heading\" ng-click=\"isOpen = !isOpen\">\n<span accordion-transclude=\"heading\">\n<a>{{ heading }}</a>\n</span>\n</div>\n<div class=\"panel-collapse\" collapse=\"!isOpen\">\n<div class=\"panel-body\" ng-transclude>\n</div>\n</div>\n</div>");
    }
  ]);

}).call(this);
