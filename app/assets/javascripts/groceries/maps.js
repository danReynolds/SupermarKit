function initialize() {
    var markers = [];
    var $input = $('#pac-input');

    var map = new google.maps.Map(document.getElementById('map-canvas'), {
        center: new google.maps.LatLng(0, 0),
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        mapTypeControl: false,
        zoom: 1
    });

    // If there is a grocery store set then change the map to that location
    if (place_id) {
        var request = { placeId: place_id };

        service = new google.maps.places.PlacesService(map);
        service.getDetails(request, function(place, status) {
            if (status == google.maps.places.PlacesServiceStatus.OK) {
                var placeLocation = new google.maps.LatLng(place.geometry.location.A, place.geometry.location.F);
                map.setCenter(placeLocation);
                placeMarkers([place], map);
                $input.val(place.name + ', ' + place.vicinity);
            }
        });
    }

    // Create the search box and link it to the UI element.
    var input = $input.get(0);
    map.controls[google.maps.ControlPosition.TOP_LEFT].push(input);

    var searchBox = new google.maps.places.SearchBox(input);

    // Listen for the event fired when the user selects an item from the
    // pick list. Retrieve the matching places for that item.
    google.maps.event.addListener(searchBox, 'places_changed', function() {
        var places = searchBox.getPlaces();

        if (places.length == 0) {
            return;
        }
        // Make the request to set the location as the new grocery store
        else if (places.length == 1) {
            var store = places[0];
            var geometry = store.geometry.location;
            $.post('/groceries/' + grocery_id + '/set_store', {
                grocery_store: {
                    lat: geometry.A,
                    lng: geometry.F,
                    name: store.name,
                    place_id: store.place_id
                }
            });
        }

        for (var i = 0, marker; marker = markers[i]; i++) {
            marker.setMap(null);
        }

        placeMarkers(places, map);
    });

    // Bias the SearchBox results towards places that are within the bounds of the
    // current map's viewport.
    google.maps.event.addListener(map, 'bounds_changed', function() {
        var bounds = map.getBounds();
        searchBox.setBounds(bounds);
    });
}

function placeMarkers(places, map) {
    // For each place, get the icon, place name, and location.
    markers = [];
    var bounds = new google.maps.LatLngBounds();
    for (var i = 0, place; place = places[i]; i++) {
        var image = {
            url: place.icon,
            size: new google.maps.Size(71, 71),
            origin: new google.maps.Point(0, 0),
            anchor: new google.maps.Point(17, 34),
            scaledSize: new google.maps.Size(25, 25)
        };

        // Create a marker for each place.
        var marker = new google.maps.Marker({
            map: map,
            icon: image,
            title: place.name,
            position: place.geometry.location
        });

        markers.push(marker);

        bounds.extend(place.geometry.location);
    }

    map.fitBounds(bounds);
}

$(document).ready(function() {
    google.maps.event.addDomListener(window, 'load', initialize);
});
