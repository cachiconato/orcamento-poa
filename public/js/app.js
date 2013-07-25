'use strict';

function HomeController($scope, $http) {

  $http.get('/agencies').success(function(data) {
    var chartData = new google.visualization.DataTable();
    chartData.addColumn('string', 'Agencia');
    chartData.addColumn('string', 'Parent');
    chartData.addColumn('number', 'Valor');
    chartData.addColumn('number', 'increase/decrease (color)');

    chartData.addRow(['Agencias', null, 0, 0]);

    data = data.splice(0, 5);
    _.each(data, function(agencia) { chartData.addRow([agencia.name, 'Agencias',  agencia.total_spent, 10]) });
    var chart = new google.visualization.TreeMap(document.getElementById('chart_orcamento'));
    var options = {
          minColor: '#f00',
          midColor: '#ddd',
          maxColor: '#0d0',
          headerHeight: 15,
          fontColor: 'black',
          showScale: true
    };
    var formatter = new google.visualization.NumberFormat( {prefix: 'R$', negativeColor: 'red', negativeParens: true});
    formatter.format(chartData, 1);

    chart.draw(chartData, options);
  });
};

var app = angular.module('orcamentoapp', []).
  config(['$routeProvider', function($routeProvider) {
  $routeProvider.
    when('/', {templateUrl: 'views/home.html', controller: HomeController}).
    otherwise({redirectTo: '/'});
}]);

