import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Pour l'upload d'image
import 'package:meditra/config/config.dart';
import 'package:meditra/sevices/remede_service.dart'; // Importer le service Firestore

class RemedeAddModal extends StatefulWidget {
  const RemedeAddModal({Key? key}) : super(key: key);

  @override
  State<RemedeAddModal> createState() => _RemedeAddModalState();
}

class _RemedeAddModalState extends State<RemedeAddModal> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _utilisationController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _precautionController = TextEditingController();
  XFile? _imageFile; // Pour stocker l'image sélectionnée

  final ImagePicker _picker = ImagePicker(); // Initialiser l'ImagePicker
  final RemedeService _remedeService = RemedeService(); // Instancier le service

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
    String filePath = 'remedes/${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Référencer le stockage Firebase
    Reference ref = FirebaseStorage.instance.ref().child(filePath);

    // Télécharger le fichier
    await ref
        .putData(imageData); // Utiliser putData avec les données de l'image

    // Récupérer l'URL de téléchargement
    String downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }

  // Fonction pour ajouter le remède dans Firestore
   Future<void> _ajouterRemede() async {
    print("Tentative d'ajout d'un remède"); // Pour le débogage

    String nom = _nomController.text;
    String description = _descriptionController.text;
    String utilisation = _utilisationController.text;
    String dosage = _dosageController.text;
    String precaution = _precautionController.text; // Nouvelle ligne pour récupérer la précaution

    if (nom.isEmpty || description.isEmpty || utilisation.isEmpty || dosage.isEmpty || precaution.isEmpty || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs et sélectionner une image.')),
      );
      return;
    }

    try {
      String imageUrl = await uploadImageToFirebase();
      await _remedeService.addRemede(nom, description, imageUrl, utilisation, dosage, precaution); // Inclure précaution

      if (mounted) {
        Navigator.of(context).pop(); 
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Remède ajouté avec succès!')),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout du remède: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Radius du modal
      ),
      title: Text('Ajouter un Remède',
          style: TextStyle(fontFamily: policePoppins)),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _nomController,
              decoration: InputDecoration(
                labelText: 'Nom du remède',
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
              controller: _utilisationController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Utilisation',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _dosageController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Dosage',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _precautionController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Précautions',
                border: OutlineInputBorder(),
              ),
            ),
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
                        style: TextStyle(fontFamily: policePoppins))
                    : Text('Aucune image',
                        style: TextStyle(fontFamily: policePoppins)),
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
          onPressed:
              _ajouterRemede, // Appeler la fonction pour ajouter le remède
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
