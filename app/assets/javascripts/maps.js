// Gmaps overrides

Gmaps.Google.Builders.Marker.prototype.infowindow_binding = function () {
  var base;
  if (this._should_close_infowindow()) {
    this.constructor.CURRENT_INFOWINDOW.close();
  }
  if (this.infowindow == null) {
    this.infowindow = this.create_infowindow();
  }
  if (this.infowindow == null) {
    return;
  }
  this.infowindow.open(this.getServiceObject().getMap(), this.getServiceObject());
  if ((base = this.marker).infowindow == null) {
    base.infowindow = this.infowindow;
  }
  return this.constructor.CURRENT_INFOWINDOW = this.infowindow;
};

var maps = {};
var mapsLoaded = {};
var mapMarkers = {};
var mapPolylines = {};
var directionsDisplay = new google.maps.DirectionsRenderer({
    suppressMarkers: true,
    polylineOptions: {strokeColor: "#394165"}
});
var directionsService = new google.maps.DirectionsService();
var directionRendererObject = [];

// set map styles
var mapStyle = [{
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#e9e9e9"}, {"lightness": 17}]
}, {
    "featureType": "landscape",
    "elementType": "geometry",
    "stylers": [{"color": "#f5f5f5"}, {"lightness": 20}]
}, {
    "featureType": "road.highway",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#ffffff"}, {"lightness": 17}]
}, {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#ffffff"}, {"lightness": 29}, {"weight": 0.2}]
}, {
    "featureType": "road.arterial",
    "elementType": "geometry",
    "stylers": [{"color": "#ffffff"}, {"lightness": 18}]
}, {
    "featureType": "road.local",
    "elementType": "geometry",
    "stylers": [{"color": "#ffffff"}, {"lightness": 16}]
}, {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [{"color": "#f5f5f5"}, {"lightness": 21}]
}, {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [{"color": "#dedede"}, {"lightness": 21}]
}, {
    "elementType": "labels.text.stroke",
    "stylers": [{"visibility": "on"}, {"color": "#ffffff"}, {"lightness": 16}]
}, {
    "elementType": "labels.text.fill",
    "stylers": [{"saturation": 36}, {"color": "#333333"}, {"lightness": 40}]
}, {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]}, {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [{"color": "#f2f2f2"}, {"lightness": 19}]
}, {
    "featureType": "administrative",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#fefefe"}, {"lightness": 20}]
}, {
    "featureType": "administrative",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#fefefe"}, {"lightness": 17}, {"weight": 1.2}]
}];

// default init map options
var mapProviderOpts = {
    streetViewControl: false,
    mapTypeControl: false,
    scrollwheel: false,
    styles: mapStyle,
    clusterer: undefined,
    center: {lat: 12.9538477, lng: 77.3507442},
    zoom: 10
};

/**
 * Letter Pin to get a numeric marker icon
 */
function letterPin(letter, color) {
  let c=color.substring(1);
  return `https://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=${letter}|${c}|FFFFFF`
}

/**
 * Set custom map marker
 *
 * @param type
 * @param color
 * @param status
 * @returns {{path: *, fillColor: *, fillOpacity: number, strokeWeight: number, scale: number}}
 */
function setMapMarkersIco(type, color, status, data) {
    var url;
    var path;
    var strokeColor = 'transparent';
    var scale = 2;
    var labelOrigin = new google.maps.Point(0, 0);
    var anchor;

    // set stroke color depending  on status
    var _color = color;
    if (typeof status !== 'undefined') {
        color = getStatusColor(status);
        strokeColor = getStatusColor(status);
    }

    // set correct path
    switch (type) {
        case 'employee':
            path = 'M5.707.59C2.787.59.427 2.95.427 5.87c0 2.924 2.36 5.283 5.28 5.283 2.92 0 5.278-2.36 5.278-5.282 0-2.92-2.358-5.28-5.278-5.28zM5.12 3.816c0-.33.258-.587.587-.587.328 0 .586.258.586.587v.352c0 .328-.258.586-.586.586-.33 0-.587-.258-.587-.587v-.353zm2.03 1.467L6.094 8.23c-.06.165-.21.282-.387.282-.176 0-.33-.105-.388-.28L4.263 5.283c-.036-.08 0-.187.094-.223.023-.01.047-.01.07-.01h2.57c.022 0 .046 0 .07.01.082.037.116.143.082.224z';
            anchor = new google.maps.Point(6, 6);
            break;
        case 'employee-number':
            path = 'M1,6a5,5 0 1,0 10,0a5,5 0 1,0 -10,0';
            scale = 2.3;
            color = '#fff'
            labelOrigin = new google.maps.Point(6, 6);
            anchor = new google.maps.Point(6, 6);
            break;
        case 'employee-number-completed':
            path = 'M1,6a5,5 0 1,0 10,0a5,5 0 1,0 -10,0';
            scale = 2.3;
            color = '#394165'
            strokeColor = '#394165'
            labelOrigin = new google.maps.Point(6, 6);
            anchor = new google.maps.Point(6, 6);
            break;
        case 'site-marker':
            path = 'M19.88 6.233c-1.228-2.2-3.168-3.896-5.753-4.792-.457-.162-.915-.293-1.387-.374-.505-.098-1.057-.163-1.624-.196h-.678c-.568.033-1.12.098-1.624.196-.49.08-.946.212-1.387.375-2.586.897-4.54 2.593-5.77 4.793C.82 7.75.252 9.64.394 11.955c.048 1.06.33 2.02.647 2.885.33.848.71 1.614 1.15 2.347 1.72 2.886 4.036 5.445 5.345 8.738.678 1.662 1.26 3.407 1.766 5.265.488 1.842.946 3.782 1.135 5.917h.678c.19-2.135.63-4.075 1.12-5.917.504-1.858 1.103-3.603 1.765-5.265 1.325-3.293 3.643-5.852 5.345-8.738.457-.733.836-1.5 1.167-2.347.315-.864.583-1.826.646-2.885.126-2.315-.425-4.206-1.277-5.722zm-9.113 9.054c-2.195 0-3.964-1.75-3.964-3.904s1.77-3.89 3.964-3.89c2.195 0 3.98 1.736 3.98 3.89 0 2.153-1.785 3.904-3.98 3.904z'
            scale = 1;
            anchor = new google.maps.Point(11, 38);
            break;
        case 'current':
            path = 'M,12,2,4.5,20.29,5.21,21,12,18,18.79,21,19.5,20.29,z';
            scale = 1;
            anchor = new google.maps.Point(10, 8);
            break;
        case 'cluster-employee':
            return letterPin(data, _color);
            break;
        case 'no-icon':
            path = '';
            scale = 0;
    }

    return {
        url: url,
        path: path,
        fillColor: color,
        fillOpacity: 1,
        strokeColor: strokeColor,
        strokeWeight: 2,
        scale: scale,
        labelOrigin: labelOrigin,
        anchor: anchor
    };
}

/**
 * Return color depending on given trip status
 *
 * @param status
 * @returns {*}
 */
function getStatusColor(status) {
    var color;

    //@TODO set the correct statuses
    switch (status) {
        case 'active':
        case 'created':
            color = '#00A89F';
            break;
        case 'warning':
            color = '#FAA732';
            break;
        case 'danger':
            color = '#DA4F49';
            break;
        case 'inverse':
            color = '#394165';
            break;
        case 'completed':
            color = '#13A89E';
            break;
        case 'on_board':
            color = '#FFF';
            break;
        case 'missed':
            color = '#DA4F49';
            break;
        default:
            color = '#394165';
            break;
    }

    return color;
}

/**
 * Set marker label color depend on status
 *
 * @param index
 * @param status
 * @returns {{text: *, color: *, fontSize: string}}
 */
function setMapMarkerLabel(index, status) {
    var color = getStatusColor(status);

    return {
        text: index.toString(),
        color: color,
        fontWeight: '700'
    }
}

function fitMapToBounds(mapId) {
  var bounds = new google.maps.LatLngBounds();
  if (mapMarkers[mapId].length) {
    mapMarkers[mapId].forEach((marker) => {
      bounds.extend(marker.serviceObject.getPosition());
    });
    maps[mapId].map.serviceObject.fitBounds(bounds);
  }
}

/**
 * Sets default map actions
 *
 * @param mapId
 * @param markersData
 * @param status
 * @param clickHandler
 */
function addMapMarkers(mapId, markersData, status, clickHandler) {
    //@TODO refactor this function in the future
    // remove markers on basic map
    if (!markersData.hasOwnProperty('data')) {
        // add markers
        mapMarkers[mapId] = maps[mapId].addMarkers(markersData);

        // set markers style
        mapMarkers[mapId].forEach(function (marker, index) {
            marker.serviceObject.set('id', markersData[index].id);
            if(markersData[index].type != null) {
                // var polyline = new google.maps.Polyline({
                //     strokeColor: '#13A89E'
                // });
                // directionsDisplay.setOptions({polylineOptions: polyline});
                setTimeout(function (marker, markersData, index) {
                  data = markersData[index];
                  console.log(setMapMarkersIco(data.type, data.color || '#13A89E', 'completed', index+1))
                  marker.serviceObject.setIcon(setMapMarkersIco(data.type, data.color || '#13A89E', 'completed', data.label || index+1))
                }, 200, marker, markersData, index);
            } else {
                marker.serviceObject.setIcon(setMapMarkersIco('employee', '#394165'));
            }
            marker.serviceObject.addListener('click', function () {
              if ($.isFunction(clickHandler)) {
                clickHandler(markersData[index]);
              }
            });
            maps[mapId].bounds.extendWith(marker);
        });
    } else {
        mapMarkers[mapId] = {
            site: maps[mapId].addMarker(markersData.site),
            data: maps[mapId].addMarkers(markersData.data)
        };

        mapMarkers[mapId].site.serviceObject.setIcon(setMapMarkersIco('site-marker', '#00A89F', status));
        maps[mapId].bounds.extendWith(mapMarkers[mapId].site);

        if (markersData.type === 'employee-basic') {
            // set marker icon
            mapMarkers[mapId].data.forEach(function (marker, index) {
                marker.serviceObject.setIcon(setMapMarkersIco('employee', '#394165', markersData.data[index].status));
                maps[mapId].bounds.extendWith(marker);
            });

        } else {
            // set employee numeric markers icon
            var label = 1;
            mapMarkers[mapId].data.forEach(function (marker, index) {
                if (index != 0) {
                    if(markersData.data[index].lat != markersData.data[index - 1].lat && markersData.data[index].lng != markersData.data[index - 1].lng) {
                        maps[mapId].bounds.extendWith(marker);
                        if (markersData.data[index].status === 'on_board') {
                            marker.serviceObject.setLabel(setMapMarkerLabel(label, markersData.data[index].status));
                            marker.serviceObject.setIcon(setMapMarkersIco('employee-number-completed', '#394165', markersData.data[index].status));
                        } else {
                            marker.serviceObject.setLabel(setMapMarkerLabel(label, markersData.data[index].status));
                            marker.serviceObject.setIcon(setMapMarkersIco('employee-number', '#fff', markersData.data[index].status));
                        }
                        label = label + 1;
                    } else {
                        marker.serviceObject.setLabel("");
                        marker.serviceObject.setIcon(setMapMarkersIco('no-icon', '#fff', markersData.data[index].status))
                    }
                } else {
                    maps[mapId].bounds.extendWith(marker);
                    if (markersData.data[index].status === 'on_board') {
                        marker.serviceObject.setLabel(setMapMarkerLabel(label, markersData.data[index].status));
                        marker.serviceObject.setIcon(setMapMarkersIco('employee-number-completed', '#394165', markersData.data[index].status));
                    } else {
                        marker.serviceObject.setLabel(setMapMarkerLabel(label, markersData.data[index].status));
                        marker.serviceObject.setIcon(setMapMarkersIco('employee-number', '#fff', markersData.data[index].status));
                    }
                    label = label + 1;                    
                }
            });
        }
    }

    // fit map
    maps[mapId].fitMapToBounds();
}

/**
 * Add polyline to map
 *
 * @param mapId
 * @param points
 */
function addPolyline(mapId, clusterId, points, options) {
  if (!mapPolylines[mapId]) {
    mapPolylines[mapId] = {};
  }
  if (mapPolylines[mapId][clusterId]) {
    // remove existing polyline
    mapPolylines[mapId][clusterId].serviceObject.setMap(null);
  }
  mapPolylines[mapId][clusterId] = maps[mapId].addPolyline(points, $.extend({
    strokeColor: "#394165"
  }, options));

  var bounds = new google.maps.LatLngBounds();
  // debugger
  Object.keys(mapPolylines[mapId]).forEach((cid) => {
    var polyline = mapPolylines[mapId][cid]
    polyline.serviceObject.getPath().forEach((item) => {
      bounds.extend(new google.maps.LatLng(item.lat(), item.lng()));
    })
  })
  setTimeout(() => {
    maps[mapId].map.serviceObject.fitBounds(bounds);
  }, 200);
}

/**
 * Remove polylines on map
 *
 * @param mapId
 */
function removePolylines(mapId, clusterId) {
  if (mapPolylines[mapId]) {
    if (clusterId) {
      mapPolylines[mapId][clusterId].serviceObject.setMap(null);
      delete mapPolylines[mapId][clusterId];
    } else {
      Object.keys(mapPolylines[mapId]).forEach((key) => {
        var polyline = mapPolylines[mapId][key];
        polyline.serviceObject.setMap(null);
      });
      mapPolylines[mapId] = {};
    }
  }
}

/**
 * Highlight marker on check table row
 *
 * @param mapId
 * @param markerId
 */
function selectMarker(mapId, markerId, color) {
    if (!color) {
      color = '#00A89F';
    }
    $.each(mapMarkers[mapId], function () {
        if (this.serviceObject.id == markerId) {
            this.serviceObject.setIcon(setMapMarkersIco('employee', color));
            // try {
            //   this.panTo();
            // } catch (err) {
            //   console.log(err);
            // }
        }
    });
}

/**
 * Removes marker selection on uncheck table row
 *
 * @param mapId
 * @param markerId
 */
function deselectMarker(mapId, markerId) {
    $.each(mapMarkers[mapId], function () {
        if (this.serviceObject.id == markerId) {
            this.serviceObject.setIcon(setMapMarkersIco('employee', '#394165'));
        }
    });
}

/**
 * Remove map markers
 *
 * @param mapId
 */
function removeMapMarkers(mapId) {
    if (maps.hasOwnProperty(mapId)) {
        directionsDisplay.setMap(null);
        for(var i = 0; i < directionRendererObject.length; i++) {
            directionRendererObject[i].setMap(null);
        }
        directionRendererObject = [];
        for (var key in mapMarkers[mapId]) {
            if (typeof mapMarkers[mapId][key].length !== 'undefined') {
                maps[mapId].removeMarkers(mapMarkers[mapId][key]);
            } else {
                maps[mapId].removeMarker(mapMarkers[mapId][key]);
            }
        }
        mapMarkers[mapId] = [];
    }
}

function removeMapMarkersGroup(mapId, markerId) {
  mapMarkers[mapId].slice(0).forEach((marker, index) => {
    if (marker.serviceObject.id === markerId) {
      // maps[mapId].removeMarker(marker);
      marker.serviceObject.setMap(null);
      mapMarkers[mapId].splice(index, 1);
    }
  });
}

/**
 * Set true if map fully loaded
 *
 * @param mapId
 */
function checkMapLoading(mapId) {
    google.maps.event.addListener(maps[mapId].getMap(), 'idle', function () {
        mapsLoaded[mapId] = true;
    });
}

/**
 * Calculate route trip direction map
 *
 * @param data
 */
function calcTripRoute(data) {
    if(data.data.length == 0)
        return;

    var waypts = [];

    var origin = {};
    var destination = {};
    if(data.data[0].type == "check_in") {
      for (var i = 1; i < data.data.length; i++) {
          waypts.push({
              location: {lat: +data.data[i].lat, lng: +data.data[i].lng}
          });
      }

      origin = {
          lat: +data.data[0].lat,
          lng: +data.data[0].lng
      };
      destination = {lat: +data.site.lat, lng: +data.site.lng};
    } else {
      for (var i = 0; i < data.data.length - 1; i++) {
          waypts.push({
              location: {lat: +data.data[i].lat, lng: +data.data[i].lng}
          });
      }

      destination = {
          lat: +data.data[data.data.length - 1].lat,
          lng: +data.data[data.data.length - 1].lng
      };
      origin = {lat: +data.site.lat, lng: +data.site.lng};
    }

    var request = {
        origin: origin,
        waypoints: waypts,
        destination: destination,
        avoidTolls: true,
        travelMode: google.maps.TravelMode.DRIVING
    };

    directionsService.route(request, function (response, status) {
        if (status == google.maps.DirectionsStatus.OK) {
            directionsDisplay.setDirections(response);
        }
    });
}

/**
 * Calculate route trip direction map
 *
 * @param data
 * @param trip
 */
function calcTripRouteMap(data, trip) {
    if (data.data.length == 0)
        return;

    if(trip.status != "completed" && trip.status != "active") {
        return;
    }

    var waypts = [];

    var origin = {};
    var destination = {};

    for (var i = 0; i < data.data.length; i++) {
        if((trip.trip_type == "check_in") && (data.data[i].status == "on_board" || data.data[i].status == "missed" || data.data[i].status == "completed")) {
            waypts.push({
                location: {lat: +data.data[i].lat, lng: +data.data[i].lng}
            });
        }
        else if((trip.trip_type == "check_out") && (data.data[i].status == "completed")) {
            waypts.push({
                location: {lat: +data.data[i].lat, lng: +data.data[i].lng}
            });
        }
    }

    if(trip.trip_type == "check_in") {
        if(trip.status == "completed") {
            if(waypts.length < 1) {
                return;
            }
            origin = waypts.shift();
            destination = {lat: +data.site.lat, lng: +data.site.lng};
        } else {
            if(waypts.length < 2) {
                return;
            }
            origin = waypts.shift();
            destination = waypts.pop();
        }
    } else {
        destination = {lat: +data.site.lat, lng: +data.site.lng};
        if(waypts.length < 1) {
            return;
        }
        origin = waypts.shift();
    }

    var request = {
        origin: origin,
        waypoints: waypts,
        destination: destination,
        avoidTolls: true,
        travelMode: google.maps.TravelMode.DRIVING
    };

    directionsService.route(request, function (response, status) {
        if (status == google.maps.DirectionsStatus.OK) {
            directionsDisplay.setDirections(response);
        }
    });
}

/**
 * Init trip info direction map
 *
 * @param data
 * @param mapId
 */
function initRouteMap(data, mapId, rowData = null, flag = false) {
    maps[mapId] = Gmaps.build('Google', {markers: {clusterer: undefined}});
    maps[mapId].buildMap({
            internal: {
                id: mapId
            },
            provider: mapProviderOpts
        },
        function () {
            // if (data.type !== 'employee-basic') {
            //     directionsDisplay.setMap(maps[mapId].getMap());
            // }
            // addMapMarkers(mapId, data, 'inverse');
            showActualMapRoute(rowData.id, mapId, data, rowData.status);
        });
}

/**
 * Set markers data for the employee trip routes
 *
 * @param tripRoutes
 * @returns {Array}
 */
function setRouteMarkersData(tripRoutes) {

    var markersData = [];
    tripRoutes.forEach(function (elem) {
        markersData.push({
            id: elem.id,
            lat: elem.lat,
            lng: elem.lng,
            status: elem.status,
            route_order: elem.route_order,
            type: elem.type
        });
    });

    return markersData;
}

/**
 * Set markers data for the employee trip routes
 *
 * @param tripRoutes
 * @returns {Array}
 */
function setUnclusteredRouteMarkersData(data) {

    var markersData = [];
    for(var i = 0; i < data.length; i++) {
        markersData.push({
            id: data[i].id,
            lat: data[i].lat,
            lng: data[i].lng,
            status: "completed",
            route_order: i,
            type: "employee-basic"
        });
    }

    return markersData;
}

/**
 * Show trip route markers on map by clicking map-marker in table
 *
 * @param e
 */
function showMapRouteOnModal(mapId, rowData) { 
    /* Initialise the map */
    maps[mapId] = Gmaps.build('Google', {markers: {clusterer: undefined}});

    maps[mapId].buildMap({
        internal: {
            id: mapId
        },
        provider: mapProviderOpts
    }, function() {
        // add markers data
        var employeesMarkersData = {
            site: {lat: rowData.site_lat, lng: rowData.site_lng},
            data: []
        };

        // add markers to map
        employeesMarkersData.data = setRouteMarkersData(rowData.trip_routes);
        showActualMapRoute(rowData.id, mapId, employeesMarkersData, rowData.status);
    });
}

/**
 * Show trip route markers on for unclustered Trips
 *
 * @param e
 */
function showRouteForUnclusteredTrips(mapId, rowData) { 
    /* Initialise the map */
    maps[mapId] = Gmaps.build('Google', {markers: {clusterer: undefined}});

    maps[mapId].buildMap({
        internal: {
            id: mapId
        },
        provider: mapProviderOpts
    }, function() {
        // add markers data
        var employeesMarkersData = {
            site: {lat: rowData[0].site_lat, lng: rowData[0].site_lng},
            data: []
        };

        // add markers to map
        employeesMarkersData.data = setUnclusteredRouteMarkersData(rowData);

        addMapMarkers(mapId, employeesMarkersData, "completed");
        showUnclusteredTripGoogleMapsRoute(rowData, rowData[0].trip_type, mapId)
        // showGoogleMapSuggestedRoute(rowData.id, mapId, employeesMarkersData, rowData.status);
    });
}


function showUnclusteredTripGoogleMapsRoute(employeesMarkersData, trip_type, mapId) {
    var waypts = [];

    var origin = {};
    var destination = {};

    if(trip_type == "Check out") {
        origin = {lat: +employeesMarkersData[0].site_lat, lng: +employeesMarkersData[0].site_lng};
        destination = {
          lat: +employeesMarkersData[employeesMarkersData.length - 1].lat,
          lng: +employeesMarkersData[employeesMarkersData.length - 1].lng
        };

        if (employeesMarkersData.length > 1) {
            for(var i = 0; i < employeesMarkersData.length - 1; i++) {
              waypts.push({
                  location: {lat: +employeesMarkersData[i].lat, lng: +employeesMarkersData[i].lng}
              });
            }
        }
    } else {
        origin = {lat: +employeesMarkersData[0].site_lat, lng: +employeesMarkersData[0].site_lng};
        destination = {
          lat: +employeesMarkersData[0].lat,
          lng: +employeesMarkersData[0].lng
        };

        if (employeesMarkersData.length > 1) {
            for(var i = employeesMarkersData.length - 1; i > 0; i--) {
              waypts.push({
                  location: {lat: +employeesMarkersData[i].lat, lng: +employeesMarkersData[i].lng}
              });
            }
        }
    }    

    var request = {
        origin: origin,
        waypoints: waypts,
        destination: destination,
        avoidTolls: true,
        travelMode: google.maps.TravelMode.DRIVING
    };

    directionsService.route(request, function (response, status) {
        if (status == google.maps.DirectionsStatus.OK) {
            renderDirections(response, maps[mapId].getMap(), "#13A89E");
        }
    });
}

/**
 * Show trip route markers on map by clicking map-marker in table
 *
 * @param e
 */
function showRouteMarkersData(e) {
    var table = $(e.data.table);
    var row = $(this).closest('tr');

    if (row.hasClass('is-selected')) {
        row.removeClass('is-selected');
        removeMapMarkers(e.data.mapId);
    } else {
        removeMapMarkers(e.data.mapId);

        // show selected row
        table.find('tr.is-selected').removeClass('is-selected');
        row.addClass('is-selected');

        var rowData = table.DataTable().row('.is-selected').data();

        // add markers data
        var employeesMarkersData = {
            site: {lat: rowData.site_lat, lng: rowData.site_lng},
            data: []
        };

        // add markers to map
        employeesMarkersData.data = setRouteMarkersData(rowData.trip_routes);
        showActualMapRoute(rowData.id, e.data.mapId, employeesMarkersData, rowData.status);
    }
}

function showActualMapRoute(id, mapId, employeesMarkersData, status) {
    $.ajax({
        type: "GET",
        url: '/trip_locations',
        data: {"id": id},
    }).done(function(response) {
      // TODO: Refactor to a configuration
      let osrmBaseURL = "http://ec2-13-232-204-242.ap-south-1.compute.amazonaws.com:5000"
        if (response.trip_locations.length < 3) {
            addMapMarkers(mapId, employeesMarkersData, status);
            showGoogleMapSuggestedRoute(employeesMarkersData, mapId);
            if (response.trip.status === 'completed') {
              return;
            }
        }

        var MarkersData = [];
        // if (response.trip_locations.length > 0) {
        //   MarkersData[0] = {
        //     id: 'id',
        //     lat: +response.trip_locations[response.trip_locations.length - 1].location.lat,
        //     lng: +response.trip_locations[response.trip_locations.length - 1].location.lng,
        //     type: 'current'
        //   };
        // }

        if (response.trip.status !== 'completed') {
          // var ws = new WebSocket("ws://" + document.location.host + '/api/v3/drivers/' + response.trip.driver_id + '/location')
          var ws = new WebSocket('ws://' + document.location.host + '/api/v3/drivers/' + response.trip.driver_id + '/location')
          ws.onmessage = (e) => {
            data = JSON.parse(e.data);
            if (!('Lat' in data)) {
              return
            }
            var driverMarker = [{
              id: "driver_" + response.trip.id,
              lat: data.Lat,
              lng: data.Lng,
              type: 'current'
            }]
            removeMapMarkersGroup(mapId, "driver_"+response.trip.id)
            addMapMarkers(mapId, driverMarker)
          }
          ws.onerror = console.log
          ws.onopen = () => {
            ws.send(JSON.stringify({eventType: 'SUBSCRIBE', topic: "" + response.trip.id}))
          }
        }


        maps[mapId] = Gmaps.build('Google', {markers: {clusterer: undefined}});

        maps[mapId].buildMap({
            internal: {
                id: mapId
            },
            provider: mapProviderOpts
        }, function () {

          $.getJSON("/api/v3/trips/" + id +"/summary?use_google=true").then((resp) => {
            if(resp.code != "Ok") {
              console.log("there were problems getting trip summary from location service")
              return
            }
            resp.matchings.forEach((m) => {
              let pts = google.maps.geometry.encoding.decodePath(m.geometry).map((p) => {
                return {lat: p.lat(), lng: p.lng()}
              });
              maps[mapId].addPolyline(pts,{strokeColor: "#394165"});
            })
          })
            showGoogleMapSuggestedRoute(employeesMarkersData, mapId);
            addMapMarkers(mapId, employeesMarkersData, status);
            //Add Drivers Current Location marker
            if(status != 'completed')
                addMapMarkers(mapId, MarkersData);
        });
    });
}

function renderDirections(result, map, color)
{
    var directionsRenderer = new google.maps.DirectionsRenderer({
        suppressMarkers: true,
        preserveViewport: true,
        polylineOptions: {strokeColor: color}
    });
    directionsRenderer.setMap(map);
    directionsRenderer.setDirections(result);
    directionRendererObject.push(directionsRenderer);
}

$(function () {

    // trigger map in hidden tab on show
    $(".trips-tabs a[data-toggle='tab']").on('shown.bs.tab', function () {
        var $map = $('.tab-pane.active').find('.map');
        if ($map.length) {
            var mapId = $map.attr('id');

            google.maps.event.trigger(maps[mapId].getMap(), 'resize');
            maps[mapId].fitMapToBounds();
        }
    });

});

/**
 * Calculate route trip direction map
 *
 * @param data
 */
function showGoogleMapSuggestedRoute(data, mapId) {
    if(data.data.length == 0)
        return;

    var waypts = [];

    var origin = {};
    var destination = {};
    if(data.data[0].type == "check_in") {
      for (var i = 1; i < data.data.length; i++) {
          waypts.push({
              location: {lat: +data.data[i].lat, lng: +data.data[i].lng}
          });
      }

      origin = {
          lat: +data.data[0].lat,
          lng: +data.data[0].lng
      };
      destination = {lat: +data.site.lat, lng: +data.site.lng};
    } else {
      for (var i = 0; i < data.data.length - 1; i++) {
          waypts.push({
              location: {lat: +data.data[i].lat, lng: +data.data[i].lng}
          });
      }

      destination = {
          lat: +data.data[data.data.length - 1].lat,
          lng: +data.data[data.data.length - 1].lng
      };
      origin = {lat: +data.site.lat, lng: +data.site.lng};
    }

    var request = {
        origin: origin,
        waypoints: waypts,
        destination: destination,
        avoidTolls: true,
        travelMode: google.maps.TravelMode.DRIVING
    };

    directionsService.route(request, function (response, status) {
        if (status == google.maps.DirectionsStatus.OK) {
            renderDirections(response, maps[mapId].getMap(), "#13A89E");
        }
    });
}

function showShareMapRoute(trip_id, employee_trip_id, mapId, dest_lat, dest_lng) {
    $.ajax({
        type: "GET",
        url: '/trip_locations',
        data: {
            "id": trip_id,
            "employee_trip_id": employee_trip_id
        },
    }).done(function(res) {
        var response = res.trip_locations
        var width = 0
        var remaining = 0
        width = moment().diff(moment(res.approximate_driver_arrive_date), 'minutes')
        trip_duration = moment(res.approximate_drop_off_date).diff(moment(res.approximate_driver_arrive_date), 'minutes')
        remaining = trip_duration - width
        if(res.employee_trip.status == 'completed'){
            $("#trip_status_text").text("COMPLETED")
            $("#duration_left").text("0")
        }
        else{
            if(remaining > 0){
                $("#duration_left").text(remaining)
            }
            else{
                $("#remaining_time").css("display","none");
                $("#delayed").css("display","block");
                $(".halfright").css("border-top", "2px solid #faca51");
                $("#status_bulb").css("background", "#faca51");
                $("#call_div").css("background", "#faca51");
                $("#call_text").css("color", "#4c4c4c");            
            }    
        }
        
        if(width < 99){
            $(".halfright").css("width",  width * 100 / res.trip.planned_approximate_duration + "%");
        }
        else{
            $(".halfright").css("width",  "99%");
        }
        var MarkersData = [];
        if(response.length < 3) {
            if(response.length == 1) {
                MarkersData[0] = {id: 'id', lat: +response[response.length - 1].location.lat, lng: +response[response.length - 1].location.lng, type: 'current'};
                addMapMarkers(mapId, MarkersData);
            }
            return;
        }

        MarkersData[0] = {id: 'id', lat: +response[response.length - 1].location.lat, lng: +response[response.length - 1].location.lng, type: 'current'};

        var i = 0;
        var j = 0;
        for(i = 1; i < response.length - 1; i++) {
            var origin = {lat: +response[i].location.lat, lng: +response[i].location.lng};
            var destination = {};
            var waypts = [];
            for(j = i + 1; j < i + 22; j++) {
                if(j == response.length - 1)
                    break;
                waypts.push({
                    location: {lat: +response[j].location.lat, lng: +response[j].location.lng}
                });
            }
            destination = {lat: +response[j].location.lat, lng: +response[j].location.lng}

            var request = {
                origin: origin ,
                destination: destination,
                waypoints: waypts,
                avoidTolls: true,
                travelMode: google.maps.TravelMode.WALKING
            };
            directionsService.route(request, function (response, status) {
                if (status == google.maps.DirectionsStatus.OK) {
                    renderDirections(response, maps[mapId].getMap(), "#13A89E");
                }
            });
            i = j - 1;
        }
        //Add Drivers Current Location marker
        MarkersData[1] = {id: 'id_dest', lat: response[response.length - 1].location.lat, lng: response[response.length - 1].location.lng, type: 'site-marker'};
        addMapMarkers(mapId, MarkersData);
    });
}

function getDistanceFromLatLonInKm(lat1,lon1,lat2,lon2) {
    var R = 6371; // Radius of the earth in km
    var dLat = deg2rad(lat2-lat1);  // deg2rad below
    var dLon = deg2rad(lon2-lon1);
    var a =
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *
    Math.sin(dLon/2) * Math.sin(dLon/2);
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    var d = R * c; // Distance in km
    return d * 1000;
}

function deg2rad(deg) {
    return deg * (Math.PI/180)
}
