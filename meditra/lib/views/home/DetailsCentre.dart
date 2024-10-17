import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:meditra/config/config.dart';
import 'package:url_launcher/url_launcher.dart';


class DetailsCentre extends StatefulWidget {
    final Map<String, dynamic> centre;

  const DetailsCentre({Key? key, required this.centre}) : super(key: key);

  @override
  State<DetailsCentre> createState() => _DetailsCentreState();
}

class _DetailsCentreState extends State<DetailsCentre> {
  LocationData? currentLocation;
  late GoogleMapController mapController;

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
    setState(() {});
  }

  // Méthode pour ouvrir Google Maps avec itinéraire
 void _openMap() async {
  final latitude = widget.centre['localisation'].latitude;
  final longitude = widget.centre['localisation'].longitude;

  // URL pour ouvrir Google Maps avec itinéraire en mode conduite
  final googleMapsUrl = 'google.navigation:q=$latitude,$longitude&mode=d';

  // Vérifier si Google Maps est installé et peut gérer cette URL
  if (await canLaunch(googleMapsUrl)) {
    await launch(googleMapsUrl);
  } else {
    // Si Google Maps n'est pas disponible, ouvrir l'URL dans un navigateur
    final webUrl = 'https://www.google.com/maps/dir/?api=1&origin=${currentLocation?.latitude},${currentLocation?.longitude}&destination=$latitude,$longitude&travelmode=driving';
    await launch(webUrl);
  }
}

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(widget.centre['nom']),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Détails'),
              Tab(text: 'Contact'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // Afficher l'image du centre
                  Center(
                    child: Image.network(
                      widget.centre['image'],
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    widget.centre['nom'],
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Adresse: ${widget.centre['adresse']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Description: ${widget.centre['description']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  // Boutons pour suivre l'itinéraire et appeler
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _openMap,
                        icon: Icon(Icons.directions,color: Colors.white,),
                        label: Text('Itinéraire',style: TextStyle(color: Colors.white),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: couleurPrincipale, // Couleur personnalisée
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: (){},
                        icon: Icon(Icons.phone,color: Colors.white,),
                        label: Text('Appeler',style: TextStyle(color: Colors.white),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: couleurPrincipale, // Couleur personnalisée
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Téléphone: ${widget.centre['telephone']}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Email: ${widget.centre['email'] ?? "Non spécifié"}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Site Web: ${widget.centre['siteWeb'] ?? "Non spécifié"}',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
