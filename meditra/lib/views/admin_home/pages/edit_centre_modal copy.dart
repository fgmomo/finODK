import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:meditra/config/config.dart';
import 'package:meditra/sevices/centres_pharma_service.dart';

class EditCentreModal extends StatefulWidget {
  final DocumentReference centreRef; // Référence du centre à modifier

  const EditCentreModal({Key? key, required this.centreRef}) : super(key: key);

  @override
  State<EditCentreModal> createState() => _EditCentreModalState();
}

class _EditCentreModalState extends State<EditCentreModal> {
  final MapController _mapController = MapController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _siteWebController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  XFile? _imageFile; // Pour stocker l'image sélectionnée
  final ImagePicker _picker = ImagePicker();
  final CentreService _centreService = CentreService();

  LatLng _selectedLocation = LatLng(12.6392, -8.0029); // Position initiale au Mali

  @override
  void initState() {
    super.initState();
    _loadCentreData();
  }

  // Fonction pour charger les données actuelles du centre
  Future<void> _loadCentreData() async {
    final centreData = await widget.centreRef.get();
    if (centreData.exists) {
      final data = centreData.data() as Map<String, dynamic>;
      setState(() {
        _nomController.text = data['nom'] ?? '';
        _adresseController.text = data['adresse'] ?? '';
        _telephoneController.text = data['telephone'] ?? '';
        _emailController.text = data['email'] ?? '';
        _siteWebController.text = data['siteWeb'] ?? '';
        _descriptionController.text = data['description'] ?? '';
        _selectedLocation = LatLng(data['latitude'] ?? 12.6392, data['longitude'] ?? -8.0029);
      });
    }
  }

  // Fonction pour choisir une image depuis la galerie
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  // Fonction pour uploader l'image sur Firebase et obtenir l'URL
  Future<String> uploadImageToFirebase() async {
    if (_imageFile == null) return '';

    final Uint8List imageData = await _imageFile!.readAsBytes();
    String filePath = 'centres/${DateTime.now().millisecondsSinceEpoch}.jpg';

    Reference ref = FirebaseStorage.instance.ref().child(filePath);
    await ref.putData(imageData);
    return await ref.getDownloadURL();
  }

  // Fonction pour mettre à jour le centre
  Future<void> _updateCentre() async {
    String nom = _nomController.text;
    String adresse = _adresseController.text;
    String telephone = _telephoneController.text;
    String email = _emailController.text;
    String siteWeb = _siteWebController.text;
    String description = _descriptionController.text;

    if (nom.isEmpty || adresse.isEmpty || telephone.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      return;
    }

    String imageUrl = '';
    if (_imageFile != null) {
      imageUrl = await uploadImageToFirebase();
    }

    // Mise à jour des données du centre
    await widget.centreRef.update({
      'nom': nom,
      'adresse': adresse,
      'telephone': telephone,
      'email': email,
      'siteWeb': siteWeb,
        'localisation': GeoPoint(_selectedLocation.latitude, _selectedLocation.longitude), // Utilisation de GeoPoint
      'description': description,
      if (imageUrl.isNotEmpty) 'image': imageUrl, // Mettre à jour l'image uniquement si elle a changé
    });

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Centre mis à jour avec succès!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Text('Modifier un Centre', style: TextStyle(fontFamily: 'Poppins')),
      content: SizedBox(
        width: 400, // Définir la largeur souhaitée
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nomController,
                decoration: InputDecoration(labelText: 'Nom du centre', border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _adresseController,
                decoration: InputDecoration(labelText: 'Adresse', border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _telephoneController,
                decoration: InputDecoration(labelText: 'Téléphone', border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _siteWebController,
                decoration: InputDecoration(labelText: 'Site Web', border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(Icons.image),
                    label: Text('Uploader Image'),
                  ),
                  SizedBox(width: 10),
                  _imageFile != null
                      ? Text('Image sélectionnée', style: TextStyle(fontFamily: 'Poppins'))
                      : Text('Aucune image', style: TextStyle(fontFamily: 'Poppins')),
                ],
              ),
              SizedBox(height: 10),
              Container(
                height: 200, // Définir la hauteur de la carte
                width: 300,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: _selectedLocation,
                    initialZoom: 6.0,
                    minZoom: 5.0,
                    maxZoom: 18.0,
                    onTap: (tapPosition, LatLng location) {
                      setState(() {
                        _selectedLocation = location; // Mettre à jour la position sélectionnée
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLocation, // Position du marqueur
                          width: 40.0,
                          height: 40.0,
                          child: Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Text('Latitude: ${_selectedLocation.latitude}, Longitude: ${_selectedLocation.longitude}'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Fermer le modal
          },
          child: Text('Annuler', style: TextStyle(fontFamily: 'Poppins')),
        ),
        ElevatedButton(
          onPressed: _updateCentre, // Mise à jour du centre
          style: ElevatedButton.styleFrom(
            backgroundColor: couleurPrincipale,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Mettre à jour',
            style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
          ),
        ),
      ],
    );
  }
}
