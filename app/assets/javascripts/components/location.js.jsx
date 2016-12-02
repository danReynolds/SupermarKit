var Location = React.createClass({
    getDefaultProps: function() {
        return {
            zoomLevel: 15,
            radius: 500
        };
    },

    getInitialState: function() {
        return {
            location: null,
        };
    },

    saveLocation: function() {
        var store;
        var location = this.state.store.geometry.location;

        if (ReactDOM.findDOMNode(this.refs.search).value.length) {
            store = {
                lat: location.lat(),
                lng: location.lng(),
                name: this.state.store.name,
                place_id: this.state.store.place_id
            }
        } else {
            this.state.map.setCenter(new google.maps.LatLng());
        }

        $.ajax({
            contentType: 'application/json',
            method: 'PATCH',
            url: this.props.url,
            data: JSON.stringify({
                grocery: {
                    store: store
                }
            })
        }).then(function(result) {
            Materialize.toast('Shopping location updated.', 1000)
        });
    },

    getDirections: function() {
        window.open(
            'https://maps.google.com/maps?saddr=Current%20Location&daddr=' + this.state.store.formatted_address,
            '_blank'
        );
    },

    placeMarkers: function(places, map) {
        var markers = [];
        var bounds = new google.maps.LatLngBounds();

        places.forEach(function(place) {
            var image = {
                url: place.icon,
                size: new google.maps.Size(71, 71),
                origin: new google.maps.Point(0, 0),
                anchor: new google.maps.Point(17, 34),
                scaledSize: new google.maps.Size(25, 25)
            };

            var marker = new google.maps.Marker({
                map: map,
                icon: image,
                title: place.name,
                position: place.geometry.location
            });

            markers.push(marker);
            bounds.extend(place.geometry.location);
        });
        map.fitBounds(bounds);
        map.setZoom(this.props.zoomLevel);
    },

    setupSearch: function(map) {
        const { coords } = this.state;
        const { place_id } = this.props;
        service = new google.maps.places.PlacesService(map);

        if (place_id) {
           // Use their assigned place
           service.getDetails({
               placeId: place_id
           }, function(place, status) {
               if (status === google.maps.places.PlacesServiceStatus.OK) {
                   var placeLocation = new google.maps.LatLng(place.geometry.location.A, place.geometry.location.F);
                   map.setCenter(placeLocation);
                   this.placeMarkers([place], map);
                   this.setState({
                       store: place
                   });
                   $('#pac-input').val(place.name + ', ' + place.vicinity);
               }
           }.bind(this));
       } else if (coords) {
            // Use their current coordinates to get the closest store
            service.nearbySearch({
                location: coords,
                radius: this.props.radius,
                type: ['grocery_or_supermarket'] // deprecated Feb 2017
            }, function(places, status) {
                if (status === google.maps.places.PlacesServiceStatus.OK) {
                    if (places.length !== 0) {
                        var place = places[0];
                        var placeLocation = new google.maps.LatLng(place.geometry.location.A, place.geometry.location.F);
                        map.setCenter(placeLocation);
                        this.placeMarkers(places, map);
                        this.setState({
                            store: place
                        });
                        $('#pac-input').val(place.name + ', ' + place.vicinity);
                    }
                }
            }.bind(this));

            var latLng = new google.maps.LatLng(coords.latitude, coords.longitude);
            var bounds = {
                bounds: new google.maps.Circle({
                    center: latLng, radius: this.props.radius
                }).getBounds()
            };
        }

        // Create the search box and link it to the UI element.
        var input = document.getElementById('pac-input');
        var searchBox = new google.maps.places.SearchBox(input, bounds);
        map.controls[google.maps.ControlPosition.TOP_LEFT].push(input);

        // Bias the SearchBox results towards current map's viewport.
        map.addListener('bounds_changed', function() {
            searchBox.setBounds(map.getBounds());
        });

        var markers = [];
        // Listen for the event fired when the user selects a prediction and retrieve
        // more details for that place.
        searchBox.addListener('places_changed', function() {
            var places = searchBox.getPlaces();

            if (places.length == 0) {
                return;
            } else if (places.length === 1) {
                this.setState({
                    store: places[0]
                }, this.saveLocation);
            }

            // Clear out the old markers.
            markers.forEach(function(marker) {
                marker.setMap(null);
            });
            markers = [];

            // For each place, get the icon, name and location.
            var bounds = new google.maps.LatLngBounds();
            places.forEach(function(place) {
                var icon = {
                    url: place.icon,
                    size: new google.maps.Size(71, 71),
                    origin: new google.maps.Point(0, 0),
                    anchor: new google.maps.Point(17, 34),
                    scaledSize: new google.maps.Size(25, 25)
                };

                // Create a marker for each place.
                markers.push(new google.maps.Marker({
                    map: map,
                    icon: icon,
                    title: place.name,
                    position: place.geometry.location
                }));

                if (place.geometry.viewport) {
                    // Only geocodes have viewport.
                    bounds.union(place.geometry.viewport);
                } else {
                    bounds.extend(place.geometry.location);
                }
            });
            map.fitBounds(bounds);
            map.setZoom(this.props.zoomLevel);
        }.bind(this));
    },

    componentDidMount: function() {
        var _this = this;
        var map = new google.maps.Map(document.getElementById('map'), {
            center: new google.maps.LatLng(0, 0),
            mapTypeId: google.maps.MapTypeId.ROADMAP,
            mapTypeControl: false,
            zoom: 1,
            zoomControlOptions: {
              position: google.maps.ControlPosition.RIGHT_CENTER
            },
            streetViewControlOptions: {
                position: google.maps.ControlPosition.RIGHT_CENTER
            }
        });

        this.setState({
            map: map
        });

        var options = {
          enableHighAccuracy: true,
          timeout: 5000,
          maximumAge: 0
        };

        navigator.geolocation.getCurrentPosition(function(response) {
            var coords = response.coords;
            var mapCoords = {
                lat: coords.latitude,
                lng: coords.longitude
            };
            _this.setState({ coords: mapCoords }, function() {
                _this.setupSearch(map);
            });
        },
        function (error) {
            _this.setupSearch(map);
        }, options);
    },

    render: function() {
        return (
            <div className='card location'>
                <div className='card-content full-width dark'>
                    <div className='card-header'>
                        <h3>Shopping Location</h3>
                        <i className='fa fa-map-marker'/>
                    </div>
                    <input
                        ref='search'
                        id='pac-input'
                        className='controls'
                        type='text'
                        placeholder='Search for shopping location'
                    />
                    <div id='map'/>
                    <a
                        onClick={this.getDirections}
                        className='btn-floating'>
                        <i className='fa fa-map'/>
                    </a>
                </div>
            </div>
        );
    }
});
