'use strict';

angular.module('kb.accordion', ['template/accordion/accordion-group.html'])
.run(['$templateCache', ($templateCache) ->
  $templateCache.put("template/accordion/accordion-group.html",
    """
    <div class="panel panel-default">
    <div class="panel-heading" ng-click="isOpen = !isOpen">
    <span accordion-transclude="heading">
    <a>{{ heading }}</a>
    </span>
    </div>
    <div class="panel-collapse" collapse="!isOpen">
    <div class="panel-body" ng-transclude>
    </div>
    </div>
    </div>
    """
  )

])