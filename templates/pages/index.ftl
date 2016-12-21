<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    [#include "../includes/head.ftl"]

    [@cms.page /]
    <!-- <base href="/index.ftl/" target="_blank"> -->
  </head>
  <body ng-app="travel"  ng-controller="MainController">
   [#include "../includes/header.ftl"]

        <div ng-view>

        </div>


    <script>
    // $(window).load(function(){
    //     var $container = $('.searchContainer');
    //     $container.isotope({
    //         filter: '*',
    //         animationOptions: {
    //             duration: 750,
    //             easing: 'linear',
    //             queue: false
    //         }
    //     });
    //
    //     $('.searchFilter select').click(function(){
    //         $('.searchContainer .current').removeClass('current');
    //         $(this).addClass('current');
    //
    //         var selector = $(this).attr('data-filter');
    //         $container.isotope({
    //             filter: selector,
    //             animationOptions: {
    //                 duration: 750,
    //                 easing: 'linear',
    //                 queue: false
    //             }
    //          });
    //          return false;
    //     });
    // });


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
          var travel = angular.module('travel',['ngRoute', 'ngAnimate' ,'ngSanitize', 'ui', 'ui.filters', 'wu.masonry']);
            travel.config(function($routeProvider) {

              $routeProvider
              .when('/', {
                 templateUrl : '${ctx.contextPath}/.resources/magnolia-travels/web-resources/views/index.html',
                 controller: 'MainController'
               })
              .when('/destination/:id', {
                templateUrl : '${ctx.contextPath}/.resources/magnolia-travels/web-resources/views/destinations.html',
                controller  : 'dashboardController'
              })
             .when('/detail/:id', {
               templateUrl : '${ctx.contextPath}/.resources/magnolia-travels/web-resources/views/detail.html',
               controller  : 'DetailController'
             })
             .when('/checkout/:id', {
               templateUrl : '${ctx.contextPath}/.resources/magnolia-travels/web-resources/views/checkout.html',
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


            .controller('dashboardController', ['$scope','$routeParams', function($scope,$routeParams){
                // console.log($scope);

                $scope.selectedDestination = $routeParams.id;
                console.log('selectedDestination',$scope.selectedDestination);

            }])

            .controller('weekendController', ['$scope',function($scope){
                $scope.tours = json;

                $scope.limit = 3;
            }])

            .controller('locationController', ['$scope', function($scope){
                $scope.tours = json;
                $scope.destinations = jsonDest;


                 angular.forEach($scope.tours, function(item){
                  console.log(item.location);
                    $scope.message = item.destiantion
                });

            }])

            .filter('removeHTMLTags', function() {
          	return function(text) {
          		return  text ? String(text).replace(/<\/?\w(?:[^"'>]|"[^"]*"|'[^']*')*>/gmi, '') : "";
              // return unescape(text);
          	};

          })

          .filter("removeDups", function(){
          return function(data) {
            if(angular.isArray(data)) {
              var result = [];
              var key = {};
              for(var i=0; i<data.length; i++) {
                var val = data[i];
                if(angular.isUndefined(key[val])) {
                  key[val] = val;
                  result.push(val);
                }
              }
              if(result.length > 0) {
                return result;
              }
            }
            return data;
          }
          })





        })();
    </script>


  </body>
</html>
