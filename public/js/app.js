'use strict';

function HomeController($scope, $http) {

  $http.get('/agencies').success(function(data) {
    var chartData = new google.visualization.DataTable();
    chartData.addColumn('string', 'Agencia');
    chartData.addColumn('number', 'Valor');

    data = data.splice(0, 5);
    _.each(data, function(agencia) { chartData.addRow([agencia.name, agencia.total_spent]) });
    var chart = new google.visualization.PieChart(document.getElementById('chart_orcamento'));
    var options = {'title':'Agencias',
                       'width':800,
                       'height':600};

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

