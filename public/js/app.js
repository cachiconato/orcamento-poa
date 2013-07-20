'use strict';

var app = angular.module('orcamentoapp', ['$strap.directives']).
  config(['$routeProvider', function($routeProvider) {
  $routeProvider.
    when('/', {templateUrl: 'views/home.html', controller: HomeController}).
    otherwise({redirectTo: '/'});
}]);

});
