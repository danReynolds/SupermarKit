var Location = React.createClass({
    getDefaultProps: function() {
        return {
            zoomLevel: 15
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

    componentDidMount: function() {
        var map = new google.maps.Map(document.getElementById('map'), {
            center: new google.maps.LatLng(0, 0),
            mapTypeId: google.maps.MapTypeId.ROADMAP,
            mapTypeControl: false,
            zoom: 1
        });

        this.setState({
            map: map
        });

        if (this.props.place_id) {
            service = new google.maps.places.PlacesService(map);
            service.getDetails({
                placeId: this.props.place_id
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
        }

        // Create the search box and link it to the UI element.
        var input = document.getElementById('pac-input');
        var searchBox = new google.maps.places.SearchBox(input);
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
                });
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
                        placeholder='Search for shopping location'/>
                    <div id='map'></div>
                    <div className='card-action wide'>
                        <a
                            onClick={this.saveLocation}
                            className='waves-effect waves-light btn'>
                            Set location
                            </a>
                        <a
                            onClick={this.getDirections}
                            className='waves-effect waves-light btn'>
                            Directions
                            </a>
                    </div>
                </div>
            </div>
        );
    }
});
