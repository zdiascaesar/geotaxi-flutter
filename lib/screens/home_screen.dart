import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/map_component.dart';
import '../components/address_input_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _locationPermissionGranted = false;
  bool _hasShownBottomSheet = false;
  bool _showMapPin = false;

  @override
  void initState() {
    super.initState();
    print('HomeScreen initState');
    WidgetsBinding.instance.addObserver(this);
    _checkLocationPermission();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAddressInputBottomSheet();
    });
  }

  @override
  void dispose() {
    print('HomeScreen dispose');
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('App lifecycle state changed to: $state');
    if (state == AppLifecycleState.resumed) {
      _checkLocationPermission();
    }
  }

  Future<void> _checkLocationPermission() async {
    print('Checking location permission');
    final permission = await Geolocator.checkPermission();
    print('Current permission status: $permission');
    setState(() {
      _locationPermissionGranted = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    });
    print('Location permission granted: $_locationPermissionGranted');

    if (!_locationPermissionGranted && !_hasShownBottomSheet) {
      _showLocationPermissionBottomSheet();
    }
  }

  void _showLocationPermissionBottomSheet() {
    print('Showing location permission bottom sheet');
    setState(() {
      _hasShownBottomSheet = true;
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => LocationPermissionBottomSheet(
        onRequestPermission: () async {
          print('User requested permission');
          Navigator.pop(context);
          await Geolocator.requestPermission();
          _checkLocationPermission();
        },
      ),
    );
  }

  void _showAddressInputBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddressInputBottomSheet(
        onMapButtonPressed: () {
          Navigator.pop(context);
          setState(() {
            _showMapPin = true;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Building HomeScreen, locationPermissionGranted: $_locationPermissionGranted');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.primary,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Sign Out'),
              onTap: () => _signOut(context),
            ),
          ],
        ),
      ),
      body: MapComponent(
        locationPermissionGranted: _locationPermissionGranted,
        showPin: _showMapPin,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddressInputBottomSheet,
        child: Icon(Icons.add_location_alt),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    print('Signing out');
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      print('Error signing out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }
}

class LocationPermissionBottomSheet extends StatelessWidget {
  final VoidCallback onRequestPermission;

  const LocationPermissionBottomSheet({Key? key, required this.onRequestPermission}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Building LocationPermissionBottomSheet');
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Установите свое местоположение',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Включите общий доступ к местоположению, чтобы ваш водитель мог видеть, где вы находитесь',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: onRequestPermission,
              child: Text('Определить'),
            ),
          ],
        ),
      ),
    );
  }
}
