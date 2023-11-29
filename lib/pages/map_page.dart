
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:location/location.dart' as location;
import 'package:provider/provider.dart';
import 'package:story_app/pages/upload_page.dart';
import '../provider/location_provider.dart';

class MapPage extends StatefulWidget {
  final Function(LatLng) onBackAddStory;

  const MapPage({Key? key, required this.onBackAddStory}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _controller;
  final location.Location _location = location.Location();
  bool _serviceEnabled = false;
  location.PermissionStatus? _permissionGranted;
  LatLng? _initialPosition;
  final Set<Marker> _markers = {};
  final _searchController = TextEditingController();
  geo.Placemark? placemark;

  @override
  void initState() {
    super.initState();
    _checkLocationServices();
  }

  void _checkLocationServices() async {
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == location.PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != location.PermissionStatus.granted) {
        return;
      }
    }

    var locationData = await _location.getLocation();

    setState(() {
      _initialPosition =
          LatLng(locationData.latitude!, locationData.longitude!);
      _markers.add(Marker(
        markerId: const MarkerId('currentLocation'),
        position: _initialPosition!,
        infoWindow: InfoWindow(
          title: 'Current Location',
          snippet:
          'Latitude: ${_initialPosition!.latitude}, Longitude: ${_initialPosition!.longitude}',
        ),
      ));
    });

    // Also update the selected location in the provider
    Provider.of<LocationProvider>(context, listen: false)
        .setSelectedLocation('Latitude: ${locationData.latitude}, Longitude: ${locationData.longitude}');
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;

    // Add a marker for the initial position when the map is created
    _markers.add(Marker(
      markerId: const MarkerId('currentLocation'),
      position: _initialPosition!,
      infoWindow: InfoWindow(
        title: 'Current Location',
        snippet:
        'Latitude: ${_initialPosition!.latitude}, Longitude: ${_initialPosition!.longitude}',
      ),
    ));
  }

  void _onSearchButtonPressed() async {
    List<geo.Location> locations =
    await geo.locationFromAddress(_searchController.text);
    if (locations.isNotEmpty) {
      var searchedPosition =
      LatLng(locations[0].latitude, locations[0].longitude);
      _controller!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: searchedPosition, zoom: 15),
        ),
      );
      setState(() {
        _markers.clear();
        _markers.add(Marker(
          markerId: const MarkerId('searchedLocation'),
          position: searchedPosition,
          infoWindow: InfoWindow(title: _searchController.text),
        ));
      });

      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
          searchedPosition.latitude, searchedPosition.longitude);
      if (placemarks.isNotEmpty) {
        String address =
            'Latitude: ${searchedPosition.latitude}, Longitude: ${searchedPosition.longitude}';
        Provider.of<LocationProvider>(context, listen: false)
            .setSelectedLocation(address);
      } else {
        // If no placemarks are available, update the selected location with latitude and longitude
        Provider.of<LocationProvider>(context, listen: false)
            .setSelectedLocation(
            'Latitude: ${searchedPosition.latitude}, Longitude: ${searchedPosition.longitude}');
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Screen'),
      ),
      body: SafeArea(
        child: _initialPosition == null
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onSubmitted: (String s) async {
                  _onSearchButtonPressed();
                },
                cursorColor: Colors.black,
                decoration: const InputDecoration(
                  hintText:
                  'Search (ex: city name or specific location)',
                  suffixIcon: Icon(
                    Icons.search,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _initialPosition!,
                      zoom: 15,
                    ),
                    onTap: (LatLng latlng) {
                      onLongPressGoogleMap(latlng);
                    },
                    mapToolbarEnabled: false,
                    myLocationButtonEnabled: false,
                    mapType: MapType.normal,
                    onMapCreated: _onMapCreated,
                    markers: _markers,
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: FloatingActionButton(

                      onPressed: () {
                        LatLng selectedLocation = _markers.first.position;
                        widget.onBackAddStory(selectedLocation);
                        debugPrint('$selectedLocation');
                      },
                      backgroundColor: Colors.blue,
                      child: const Icon(Icons.check),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onLongPressGoogleMap(LatLng latlng) async {
    setState(() {
      placemark = null;
    });

    final marker = Marker(
      markerId: const MarkerId("currentLocation"),
      position: latlng,
      infoWindow: InfoWindow(
        title: 'Latitude: ${latlng.latitude.toStringAsFixed(6)}',
        snippet: 'Longitude: ${latlng.longitude.toStringAsFixed(6)}',
      ),
    );

    setState(() {
      _markers.clear();
      _markers.add(marker);
    });

    Provider.of<LocationProvider>(context, listen: false)
        .setSelectedLocation('Latitude: ${latlng.latitude}, Longitude: ${latlng.longitude}');

    _controller!.animateCamera(
      CameraUpdate.newLatLng(latlng),
    );
  }

}
