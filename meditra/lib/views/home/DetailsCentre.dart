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
  void _callPhoneNumber(String phoneNumber) async {
  final telUrl = 'tel:$phoneNumber';
  if (await canLaunch(telUrl)) {
    await launch(telUrl);
  } else {
    throw 'Impossible d\'ouvrir le numéro $phoneNumber';
  }
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
          elevation: 0, // Retirer l'ombre sous l'appBar pour un look minimaliste
          title: Text(
            widget.centre['nom'],
            style: TextStyle(
              color: couleurPrincipale,
              fontFamily: policePoppins,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: IconThemeData(color: couleurPrincipale),
          bottom: TabBar(
            indicatorColor: couleurPrincipale, 
            labelColor: couleurPrincipale,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(
              fontFamily: policePoppins, 
              fontSize: 16, 
              fontWeight: FontWeight.w600,
            ),
            tabs: [
              Tab(text: 'Détails'),
              Tab(text: 'Contact'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Contenu de la première vue (Détails)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // Image avec un petit effet d'ombre et des coins arrondis
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 2,
                            offset: Offset(0, 2),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          widget.centre['image'],
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Nom du centre avec un style distinct
                  Text(
                    widget.centre['nom'],
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: couleurPrincipale,
                    ),
                  ),
                  SizedBox(height: 10),
                  // Adresse du centre
                  Row(
                    children: [
                      Icon(Icons.location_pin, color: couleurPrincipale),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          widget.centre['adresse'],
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Description
                  Text(
                    'Description:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: couleurPrincipale,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    widget.centre['description'],
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(height: 20),
                  // Boutons d'actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _openMap,
                        icon: Icon(Icons.directions, color: Colors.white),
                        label: Text('Itinéraire', style: TextStyle(color: Colors.white,fontFamily: policePoppins)),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: couleurPrincipale,
                        ),
                      ),
                      //   ElevatedButton.icon(
                      //   onPressed: _openMap,
                      //   icon: Icon(Icons.message_sharp, color: Colors.white),
                      //   label: Text('SMS', style: TextStyle(color: Colors.white,fontFamily: policePoppins)),
                      //   style: ElevatedButton.styleFrom(
                      //     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(10),
                      //     ),
                      //     backgroundColor: couleurPrincipale,
                      //   ),
                      // ),
                      ElevatedButton.icon(
                        onPressed: (){
                            _callPhoneNumber(widget.centre['telephone']);
                        },
                        icon: Icon(Icons.phone, color: Colors.white),
                        label: Text('Appeler', style: TextStyle(color: Colors.white,fontFamily: policePoppins)),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: couleurPrincipale,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Contenu de la deuxième vue (Contact)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contactez-nous',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: couleurPrincipale,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Téléphone
                  Row(
                    children: [
                      Icon(Icons.phone, color: couleurPrincipale),
                      SizedBox(width: 10),
                      Text(
                        'Téléphone: ${widget.centre['telephone']}',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Email
                  Row(
                    children: [
                      Icon(Icons.email, color: couleurPrincipale),
                      SizedBox(width: 10),
                      Text(
                        'Email: ${widget.centre['email'] ?? "Non spécifié"}',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Site Web
                  Row(
                    children: [
                      Icon(Icons.web, color: couleurPrincipale),
                      SizedBox(width: 10),
                      Text(
                        'Site Web: ${widget.centre['siteWeb'] ?? "Non spécifié"}',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
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
