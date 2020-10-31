import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GoogleMapController _mapController;
  List<Marker> markers = [];
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position _currentPosition;
  String _currentAddress;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  addMarker(coordinate) {
    int id = Random().nextInt(100);
    setState(() {
      markers.add(Marker(
          infoWindow: InfoWindow(title: coordinate.toString()),
          position: coordinate,
          markerId: MarkerId(id.toString())));
    });
  }

  static final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(23.810331, 90.412521), //dhaka
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: GoogleMap(
            initialCameraPosition: _initialPosition,
            mapType: MapType.normal,
            markers: markers.toSet(),
            onMapCreated: (controller) {
              setState(() {
                _mapController = controller;
              });
            },
            onTap: (coordinate) {
              _mapController.animateCamera(CameraUpdate.newLatLng(coordinate));
              addMarker(coordinate);
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add_location,
            color: Colors.green,
          ),
          onPressed: () {
            moveToCurrentLocation();
          },
        ),
      ),
    );
  }

  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });

      _getAddressFromLatLng(
          _currentPosition.latitude, _currentPosition.longitude);
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng(lat, lng) async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(lat, lng);

      Placemark place = p[0];

      setState(() {
        _currentAddress = "${place.name} , ${place.postalCode}";
      });
    } catch (e) {
      print(e);
    }
  }

  void moveToCurrentLocation() {
    if (_currentAddress != null && _currentPosition != null) {
      LatLng currentLatlng =
          LatLng(_currentPosition.latitude, _currentPosition.longitude);
      _mapController
          .animateCamera(CameraUpdate.newLatLngZoom(currentLatlng, 14.4746));
      setState(() {
        markers.add(Marker(
          position: currentLatlng,
          markerId: MarkerId("current_m_id"),
          infoWindow: InfoWindow(title: _currentAddress),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        ));
      });
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("GeoLocation getting problem!"),
              actions: [
                FlatButton(
                    onPressed: () => Navigator.of(context).pop,
                    child: Text("Close"))
              ],
            );
          });
    }
  }
}
