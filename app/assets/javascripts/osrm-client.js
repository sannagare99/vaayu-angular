$(function () {
  let baseUrl = "http://ec2-13-232-204-242.ap-south-1.compute.amazonaws.com:5000";
  let profile = "driving";
  let apiVersion = "v1";
  let tripService = "trip";
  let routeService = "route";

  function getLocations(points) {
    return points.map((point) => point.lng + ',' + point.lat).join(';');
  }

  function getUrl(service, locations) {
    return baseUrl +
      '/' + service +
      '/' + apiVersion +
      '/' + profile +
      '/' + locations;
  }

  window.osrm_client = {
    get: function(url, options) {
      options = $.extend({
        steps: false,
        overview: 'simplified'
      }, options);
      return $.getJSON(url + '?' + $.param(options));
    },

    getRoute: function (points, options) {
      return this.get(getUrl(routeService, getLocations(points)), $.extend({
        alternatives: false,
      }, options));
    },

    getTrip : function (points, options) {
      return this.get(getUrl(tripService, getLocations(points)), $.extend({
        source: 'first',
        roundtrip: false,
        destination: 'last',
      }, options));
    }
  };
});
