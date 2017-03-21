<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    [#include "../includes/head.ftl"]

    [@cms.page /]
  </head>
  <body ng-app="travel"  ng-controller="MainController">
   [#include "../includes/header.ftl"]

        <div ng-view>

        </div>


    <script>


    [#assign workspace = "tours"]
    [#assign mainNodeType = "mgnl:content"]

    [#assign node = cmsfn.contentByPath("/", workspace)]
    [#macro scan node]
        [#assign nodeChilds = cmsfn.children(node)]
        [#list nodeChilds as item]
                [#if item["jcr:primaryType"] == "mgnl:folder"]
                    [@scan item/]
                [#elseif item["jcr:primaryType"] == mainNodeType]
                  [#assign json = jsonfn.appendFrom(json!"[]",item).expand("tourTypes", "category").expand("destination","category").expand("image", "dam").add("name","body", "description", "duration", "location","displayName", "author","tourTypes","destination","@link", "@id", "@path", "@name").print()]
                [/#if]
            [/#list]
        [/#macro]

    [@scan node/]

    var json = ${json!};


    [#assign destionationsNode = cmsfn.contentByPath("/destinations", "category")]
    [#assign jsonDest = jsonfn.fromChildNodesOf(destionationsNode).addAll().print()]

    var jsonDest = ${jsonDest!};

    [#assign tourTypesNode = cmsfn.contentByPath("/tour-types", "category")]
    [#assign jsonTourType = jsonfn.fromChildNodesOf(tourTypesNode).expand("image", "dam").addAll().print()]

    var jsonTourType = ${jsonTourType!};


        (function () {
          var travel = angular.module('travel',['ngRoute', 'ngAnimate' ,'ngSanitize', 'ui', 'ui.filters']);
            travel.config(function($routeProvider) {

              $routeProvider
              .when('/', {
                 templateUrl : '${ctx.contextPath}/.resources/angular-travel-demo/webresources/views/index.html',
                 controller: 'MainController'
               })
             .when('/detail/:id', {
               templateUrl : '${ctx.contextPath}/.resources/angular-travel-demo/webresources/views/detail.html',
               controller  : 'DetailController'
             })
             .when('/checkout/:id', {
               templateUrl : '${ctx.contextPath}/.resources/angular-travel-demo/webresources/views/checkout.html',
               controller  : 'DetailController'
             });

           })

            travel.controller('MainController', ['$scope',function($scope){
                $scope.searchLocation   = [];
                $scope.selectedDuration = [];    // set the default search/filter term
                $scope.tours = json;
                $scope.destinations = jsonDest;
                $scope.tourTypes = jsonTourType;
                console.log('tours',$scope.tours);
                console.log('destinations',$scope.destinations);
                console.log('tourTypes',$scope.tourTypes)
            }])

            .controller('DetailController', ['$scope','$routeParams' ,function($scope,$routeParams,$sanitize){
                var detailId = $routeParams.id;

                $scope.tours.forEach(function(item) {
                  if(detailId == item['@name']){
                      $scope.selectedTour = item;
                  }
                });

                console.log('selectedTour',$scope.selectedTour);
            }])

        })();
    </script>


  </body>
</html>
