import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';

class MapComponent extends StatefulWidget {
  final bool locationPermissionGranted;
  final bool showPin;

  const MapComponent({
    Key? key,
    required this.locationPermissionGranted,
    required this.showPin,
  }) : super(key: key);

  @override
  _MapComponentState createState() => _MapComponentState();
}

class _MapComponentState extends State<MapComponent> {
  LatLng _currentLocation = LatLng(55.7558, 37.6173); // Default to Moscow
  late MapController _mapController;
  static const LatLng _moscowLocation = LatLng(55.7558, 37.6173);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    print('MapComponent initState: locationPermissionGranted = ${widget.locationPermissionGranted}');
    if (widget.locationPermissionGranted) {
      _getCurrentLocation();
    } else {
      _setMoscowLocation();
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _setMoscowLocation() {
    print('Setting Moscow location');
    setState(() {
      _currentLocation = _moscowLocation;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(_moscowLocation, 10);
    });
  }

  Future<void> _getCurrentLocation() async {
    print('Getting current location');
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print('Current location: ${position.latitude}, ${position.longitude}');
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(_currentLocation, 15);
      });
    } catch (e) {
      print("Error getting location: $e");
      _setMoscowLocation();
    }
  }

  Future<void> _requestLocationPermission() async {
    print('Requesting location permission');
    LocationPermission permission = await Geolocator.requestPermission();
    print('Permission result: $permission');
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      _getCurrentLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: _currentLocation,
            zoom: 15,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://api.mapbox.com/styles/v1/mapbox/light-v10/tiles/{z}/{x}/{y}?access_token={accessToken}',
              additionalOptions: const {
                'accessToken':
                    'pk.eyJ1IjoiNmVremhhbiIsImEiOiJjbHppM214dWswYjB1MmtzNDRsdno4ZmFxIn0.LVh6MJeD2z0AViZebxN1-A',
              },
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: _currentLocation,
                  width: 24,
                  height: 24,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.5),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                if (widget.showPin)
                  Marker(
                    point: _currentLocation,
                    width: 48,
                    height: 48,
                    child: SvgPicture.asset(
                      'lib/assets/ic_pick.svg',
                      width: 48,
                      height: 48,
                    ),
                  ),
              ],
            ),
          ],
        ),
        Positioned(
          right: 16,
          top: 16,
          child: FloatingActionButton(
            onPressed: widget.locationPermissionGranted ? _getCurrentLocation : _requestLocationPermission,
            child: Icon(Icons.my_location, color: Colors.white),
            backgroundColor: AppColors.primary,
            mini: true,
          ),
        ),
      ],
    );
  }
}
