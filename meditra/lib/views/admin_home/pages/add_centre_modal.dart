import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:meditra/config/config.dart';
import 'package:meditra/sevices/centres_pharma_service.dart'; // Pour obtenir la position actuelle

class CentreAddModal extends StatefulWidget {
  const CentreAddModal({Key? key}) : super(key: key);

  @override
  State<CentreAddModal> createState() => _CentreAddModalState();
}

class _CentreAddModalState extends State<CentreAddModal> {
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

  // Fonction pour ajouter le centre
  Future<void> _ajouterCentre() async {
    String nom = _nomController.text;
    String adresse = _adresseController.text;
    String telephone = _telephoneController.text;
    String email = _emailController.text;
    String siteWeb = _siteWebController.text;
    String description = _descriptionController.text;

    if (nom.isEmpty ||
        adresse.isEmpty ||
        telephone.isEmpty ||
        description.isEmpty ||
        _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Veuillez remplir tous les champs et sélectionner une image.')),
      );
      return;
    }

    String imageUrl = await uploadImageToFirebase();

    await _centreService.ajouterCentrePharmacopee(
      nom: nom,
      adresse: adresse,
      telephone: telephone,
      email: email,
      siteWeb: siteWeb,
      
      latitude: _selectedLocation.latitude,
      longitude: _selectedLocation.longitude,
      description: description,
      image: imageUrl,
    );

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Centre ajouté avec succès!')),
    );
     setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Text('Ajouter un Centre', style: TextStyle(fontFamily: 'Poppins')),
        content: SizedBox(
    width: 400,  // Définir la largeur souhaitée
    child: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _nomController,
              decoration: InputDecoration(
                  labelText: 'Nom du centre', border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _adresseController,
              decoration: InputDecoration(
                  labelText: 'Adresse', border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _telephoneController,
              decoration: InputDecoration(
                  labelText: 'Téléphone', border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                  labelText: 'Email', border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _siteWebController,
              decoration: InputDecoration(
                  labelText: 'Site Web', border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                  labelText: 'Description', border: OutlineInputBorder()),
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
                    ? Text('Image sélectionnée',
                        style: TextStyle(fontFamily: 'Poppins'))
                    : Text('Aucune image',
                        style: TextStyle(fontFamily: 'Poppins')),
              ],
            ),
            SizedBox(height: 10),
           Container(
  height: 200, // Définir la hauteur de la carte
  width: 300,
  child: FlutterMap(
    options: MapOptions(
      initialCenter: _selectedLocation, // Utiliser _selectedLocation pour centrer
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
            Text(
                'Latitude: ${_selectedLocation.latitude}, Longitude: ${_selectedLocation.longitude}'),
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
          onPressed: _ajouterCentre,
          style: ElevatedButton.styleFrom(
            backgroundColor: couleurPrincipale,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Ajouter',
            style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
          ),
        ),
   
      ],
    );
  }
}
