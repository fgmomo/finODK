import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meditra/sevices/remede_service.dart'; // Assurez-vous d'importer votre service Firestore

class EditRemedeModal extends StatefulWidget {
  final DocumentReference remedeRef; // Référence du remède à modifier

  const EditRemedeModal({Key? key, required this.remedeRef}) : super(key: key);

  @override
  State<EditRemedeModal> createState() => _EditRemedeModalState();
}

class _EditRemedeModalState extends State<EditRemedeModal> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _utilisationController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _precautionController = TextEditingController();
  XFile? _imageFile; // Pour stocker l'image sélectionnée
  String? _imageUrl; // Pour stocker l'URL de l'image existante

  final ImagePicker _picker = ImagePicker(); // Initialiser l'ImagePicker
  final RemedeService _remedeService = RemedeService(); // Instancier le service

  @override
  void initState() {
    super.initState();
    _loadRemedeData(); // Charger les données du remède au démarrage
  }

  // Fonction pour charger les données du remède depuis Firestore
  Future<void> _loadRemedeData() async {
    DocumentSnapshot doc = await widget.remedeRef.get();
    Remede remede = Remede.fromDocument(doc);

    // Initialiser les contrôleurs avec les données du remède
    _nomController.text = remede.nom;
    _descriptionController.text = remede.description;
    _utilisationController.text = remede.utilisation;
    _dosageController.text = remede.dosage;
    _precautionController.text = remede.precaution;

    // Vérifier si l'URL de l'image existe
    if (remede.image.isNotEmpty) {
      _imageUrl = remede.image; // Assigner l'URL de l'image existante
    }
  }

  // Fonction pour choisir une image depuis la galerie
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile; // Assigner l'image sélectionnée
      _imageUrl = null; // Réinitialiser l'URL de l'image existante si une nouvelle image est sélectionnée
    });
  }

  // Fonction pour modifier le remède dans Firestore
  Future<void> _modifierRemede() async {
  String nom = _nomController.text;
  String description = _descriptionController.text;
  String utilisation = _utilisationController.text;
  String dosage = _dosageController.text;
  String precaution = _precautionController.text;

  if (nom.isEmpty || description.isEmpty || utilisation.isEmpty || dosage.isEmpty || precaution.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Veuillez remplir tous les champs et sélectionner une image.')),
    );
    return;
  }

  String imageUrl;

  // Vérifier si une nouvelle image a été sélectionnée
  if (_imageFile != null) {
    // Télécharger l'image sur Firebase Storage
    String fileName = DateTime.now().millisecondsSinceEpoch.toString(); // Générer un nom unique
    Reference storageRef = FirebaseStorage.instance.ref().child('remedes/$fileName.jpg');

    // Uploader l'image en utilisant les bytes
    final Uint8List imageBytes = await _imageFile!.readAsBytes();
    await storageRef.putData(imageBytes); // Utiliser putData pour uploader les bytes
    imageUrl = await storageRef.getDownloadURL(); // Obtenir l'URL de l'image téléchargée
  } else {
    // Si aucune nouvelle image n'est sélectionnée, utiliser l'URL existante
    imageUrl = _imageUrl!;
  }

  // Créer un objet Remede modifié
  Remede remedeModifie = Remede(
    nom: nom,
    description: description,
    utilisation: utilisation,
    dosage: dosage,
    precaution: precaution,
    image: imageUrl,
  );

  // Modifier le remède dans Firestore via le service
  await _remedeService.updateRemede(widget.remedeRef, remedeModifie); // Utiliser la référence du remède

  Navigator.of(context).pop();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Remède modifié avec succès!')),
  );
}

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Text('Modifier le Remède'),
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
              decoration: InputDecoration(
                labelText: 'Utilisation',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _dosageController,
              decoration: InputDecoration(
                labelText: 'Dosage',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _precautionController,
              decoration: InputDecoration(
                labelText: 'Précautions',
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
                    ? Text('Image sélectionnée')
                    : _imageUrl != null
                        ? Text('Image existante sélectionnée')
                        : Text('Aucune image'),
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
          child: Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _modifierRemede, // Appeler la fonction pour modifier le remède
          child: Text('Modifier'),
        ),
      ],
    );
  }
}
