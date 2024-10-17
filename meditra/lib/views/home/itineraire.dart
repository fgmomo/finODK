import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ItinerairePage extends StatefulWidget {
  final Map<String, dynamic> centre;

  const ItinerairePage({Key? key, required this.centre}) : super(key: key);

  @override
  _ItinerairePageState createState() => _ItinerairePageState();
}

class _ItinerairePageState extends State<ItinerairePage> {
  LocationData? currentLocation;
  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  LatLng? _destination;
  List<LatLng> _polylineCoordinates = [];
  bool _loadingRoute = false;

  // Obtenir la localisation actuelle
  Future<void> _getCurrentLocation() async {
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) return;
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }

    currentLocation = await location.getLocation();
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('currentLocation'),
          position: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          infoWindow: InfoWindow(title: 'Votre Position'),
        ),
      );
    });
  }

  // Méthode pour obtenir l'itinéraire via Google Directions API
  Future<void> _getRoute() async {
    setState(() {
      _loadingRoute = true;
    });

    final latitude = widget.centre['localisation'].latitude;
    final longitude = widget.centre['localisation'].longitude;

    final apiKey = 'VOTRE_API_KEY'; // Remplacez par votre clé API Google
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${currentLocation?.latitude},${currentLocation?.longitude}&destination=$latitude,$longitude&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final points = data['routes'][0]['overview_polyline']['points'];
      _polylineCoordinates = _decodePolyline(points);

      setState(() {
        _destination = LatLng(latitude, longitude);
        _markers.add(
          Marker(
            markerId: MarkerId('destination'),
            position: _destination!,
            infoWindow: InfoWindow(title: widget.centre['nom']),
          ),
        );
      });
    }

    setState(() {
      _loadingRoute = false;
    });
  }

  // Décoder l'itinéraire polyline
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polylineCoordinates = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polylineCoordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polylineCoordinates;
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _getRoute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Itinéraire vers ${widget.centre['nom']}'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(currentLocation?.latitude ?? 0.0, currentLocation?.longitude ?? 0.0),
              zoom: 14.0,
            ),
            markers: _markers,
            polylines: {
              Polyline(
                polylineId: PolylineId('route'),
                points: _polylineCoordinates,
                color: Colors.blue,
                width: 5,
              ),
            },
            onMapCreated: (controller) {
              mapController = controller;
            },
          ),
          if (_loadingRoute)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
