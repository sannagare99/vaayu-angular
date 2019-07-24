$(function () {
    'use strict';

    /**
     * Init map
     */
    var mapShareTripId = 'map-share-trip';
    var MarkersData = [];
    var lat = $('#map-share-trip').data( "lat" );
    var lng = $('#map-share-trip').data( "lng" );
    var dest_lat = $('#map-share-trip').data( "dest_lat" );
    var dest_lng = $('#map-share-trip').data( "dest_lng" );
    var trip_id = $('#map-share-trip').data('trip_id')
    var employee_trip_id = $('#map-share-trip').data('employee_trip_id')

    if ($('#map-share-trip').length) {
        maps[mapShareTripId] = Gmaps.build('Google', {markers: {clusterer: undefined}});

        maps[mapShareTripId].buildMap({
            internal: {
                id: mapShareTripId
            },
            provider: mapProviderOpts
        }, function () {
            redrawView(mapShareTripId);
        });
        // redraw maps view for share trip
        setInterval(function () {            
            redrawView(mapShareTripId);
        }, 100000);

        function redrawView(mapShareTripId) {
            removeMapMarkers(mapShareTripId);
            showShareMapRoute(trip_id, employee_trip_id, mapShareTripId, dest_lat, dest_lng)
        }        

        // function getTripDuration(){
        //     $.ajax({
        //         type: "GET",
        //         url: '/trips/' + trip_id
        //     }).done(function(response){
        //         console.log(response)
        //     })
        // }
    }    
});
