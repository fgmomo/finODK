import 'dart:typed_data'; // Importer pour Uint8List
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Pour l'upload d'image

import 'package:meditra/config/config.dart';
import 'package:meditra/sevices/plante_service.dart'; // Importer le service Firestore

class PlanteModal extends StatefulWidget {
  const PlanteModal({Key? key}) : super(key: key);

  @override
  State<PlanteModal> createState() => _PlanteModalState();
}

class _PlanteModalState extends State<PlanteModal> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _nomLocalController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _bienfaitsController = TextEditingController();
  XFile? _imageFile; // Pour stocker l'image sélectionnée

  final ImagePicker _picker = ImagePicker(); // Initialiser l'ImagePicker
  final PlanteService _planteService = PlanteService(); // Instancier le service

  // Fonction pour choisir une image depuis la galerie
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile; // Assigner l'image sélectionnée
    });
  }

  // Fonction pour télécharger l'image sur Firebase Storage
  Future<String> uploadImageToFirebase() async {
    // Si l'image est nulle, retourner une chaîne vide
    if (_imageFile == null) return '';

    // Lire l'image et obtenir les données
    final Uint8List imageData = await _imageFile!.readAsBytes();

    // Obtenir le chemin de stockage
    String filePath = 'plantes/${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Référencer le stockage Firebase
    Reference ref = FirebaseStorage.instance.ref().child(filePath);

    // Télécharger le fichier
    await ref.putData(imageData); // Utiliser putData avec les données de l'image

    // Récupérer l'URL de téléchargement
    String downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }

  // Fonction pour ajouter la plante dans Firestore
  Future<void> _ajouterPlante() async {
    print("Tentative d'ajout d'une plante"); // Pour le débogage

    String nom = _nomController.text;
    String nomLocal = _nomLocalController.text;
    String description = _descriptionController.text;
    String bienfaits = _bienfaitsController.text;

    if (nom.isEmpty || nomLocal.isEmpty || description.isEmpty || bienfaits.isEmpty || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs et sélectionner une image.')),
      );
      return;
    }

    // Téléchargement de l'image et obtention de l'URL
    String imageUrl = await uploadImageToFirebase();

    Plante nouvellePlante = Plante(
      nom: nom,
      nomLocal: nomLocal,
      description: description,
      bienfaits: bienfaits,
      imageUrl: imageUrl,
    );

    // Ajouter la plante dans Firestore via le service
    await _planteService.addPlante(nouvellePlante);

    // Fermer le modal et afficher un message de succès
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Plante ajoutée avec succès!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Radius du modal
      ),
      title: Text('Ajouter une Plante', style: TextStyle(fontFamily: policePoppins)),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _nomController,
              decoration: InputDecoration(
                labelText: 'Nom de la plante',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _nomLocalController,
              decoration: InputDecoration(
                labelText: 'Nom Local',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _bienfaitsController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Bienfaits',
                border: OutlineInputBorder(),
              ),
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
                    ? Text('Image sélectionnée', style: TextStyle(fontFamily: policePoppins))
                    : Text('Aucune image', style: TextStyle(fontFamily: policePoppins)),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Ferme le modal
          },
          child: Text('Annuler', style: TextStyle(fontFamily: policePoppins)),
        ),
        ElevatedButton(
          onPressed: _ajouterPlante, // Appeler la fonction pour ajouter la plante
          style: ElevatedButton.styleFrom(
            backgroundColor: couleurPrincipale,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Radius du bouton
            ),
          ),
          child: Text(
            'Ajouter',
            style: TextStyle(
              color: Colors.white, // Texte en blanc
              fontFamily: policePoppins,
            ),
          ),
        ),
      ],
    );
  }
}
