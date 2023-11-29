
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:location/location.dart' as location;
import '../data/model/list_story.dart';



class StoriesDetailPage extends StatefulWidget {
  static const routeName = '/detail_page';
  final ListStory? storiesId;

  const StoriesDetailPage ({required this.storiesId, super.key,});

  @override
  State<StoriesDetailPage> createState() => _StoriesDetailPageState();
}

class _StoriesDetailPageState extends State<StoriesDetailPage> {
  late GoogleMapController mapController;
  final Set<Marker> markers = {};
  MapType selectedMapType = MapType.normal;
  geo.Placemark? placemark;


  final location.Location _location = location.Location();
  bool _serviceEnabled = false;
  location.PermissionStatus? _permissionGranted;

  LatLng? _userLocation;

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



    setState(()  {

      _userLocation = LatLng(widget.storiesId!.lat, widget.storiesId!.lon );


      markers.add(Marker(
        markerId: const MarkerId('currentLocation'),
        position: _userLocation!,
          infoWindow: InfoWindow(
            title: 'Location',
            snippet: 'Latitude: ${widget.storiesId!.lat}, Longitude: ${widget.storiesId!.lon}',
          ),
      ));
    });
  }

  @override
  void initState() {
    super.initState();
    _checkLocationServices();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.storiesId?.name ?? ''),
      ),
      body: _buildBody(data:widget.storiesId),
    );
  }

  Widget _buildBody({ListStory? data}) {

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 30,
          ),
          Hero(
            tag: data?.id ?? '',
            child: Container(
              margin: const EdgeInsets.only(right: 10, left: 10),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    cacheKey: '${data?.photoUrl}',
                    imageUrl: '${data?.photoUrl}',
                    fit: BoxFit.contain,

                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) =>
                    const Icon(Icons.error),
                    // Optional parameters:
                    cacheManager: CacheManager(
                      Config(
                        'photoUrl-cache',
                        stalePeriod: const Duration(days: 7),
                        maxNrOfCacheObjects: 200,
                      ),
                    ),
                    // maxHeightDiskCache: 100,
                    // maxWidthDiskCache: 100,
                  ),

                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Center(
                child: Text(
                  '${data?.name}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold
                  ),
                ),
              )

          ),
          const SizedBox(
            height: 10,
          ),
          Container(
              padding: const EdgeInsets.all(16.0),
              child:Center(
                child: Text(
                  '${data?.description}',
                  overflow: TextOverflow.clip,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              )

          ),
          const SizedBox(
            height: 30,
          ),
          Container(
            margin: const EdgeInsets.only(left: 10),
            child: const Text(
              'Location',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 10,
              ),
              Row(
                children: [
                  Text(
                      '${data?.lat}'
                  ),
                ],
              ),
              const SizedBox(
                width: 10,
              ),
              Row(
                children: [
                  Text(
                      '${data?.lon}'
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),
          widget.storiesId?.lon != null || widget.storiesId?.lat != null ?
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 400,

            child: GoogleMap(
              mapType: MapType.normal,
              markers: markers,
              mapToolbarEnabled: false,
              myLocationButtonEnabled: false,
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  data!.lat,
                  data!.lon,
                ),
                zoom: 15,
              ),

              onLongPress: (LatLng latLng) => infoWindow(latLng),
            ),
          )
              : Text(
            "Location Not Found",
            style:
            Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(
            height: 10,
          ),

        ],
      ),
    );
  }

  void infoWindow(LatLng latlng) async {
    final info = await geo.placemarkFromCoordinates(latlng.latitude, latlng.longitude);

    final place = info[0];
    final street = place.street ?? '';
    final address = '${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';

    setState(() {
      placemark = place;
    });

    _userLocation = LatLng(widget.storiesId!.lat, widget.storiesId!.lon);

    final marker = Marker(
      markerId: const MarkerId('Dicoding'),
      position: _userLocation!,
      infoWindow: InfoWindow(title: street, snippet: address),
      onTap: () {
        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(
            _userLocation!,
            18,
          ),
        );
      },
    );
    markers.add(marker);
  }



}

