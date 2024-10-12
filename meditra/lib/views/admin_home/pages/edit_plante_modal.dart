import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';
import 'package:image_picker/image_picker.dart'; // Pour l'upload d'image
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:meditra/sevices/plante_service.dart'; // Importer le service Firestore

class EditPlanteModal extends StatefulWidget {
  final DocumentReference planteRef; // Référence de la plante à modifier

  const EditPlanteModal({Key? key, required this.planteRef}) : super(key: key);

  @override
  State<EditPlanteModal> createState() => _EditPlanteModalState();
}

class _EditPlanteModalState extends State<EditPlanteModal> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _nomLocalController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _bienfaitsController = TextEditingController();
  XFile? _imageFile; // Pour stocker l'image sélectionnée
  String? _imageUrl; // Pour stocker l'URL de l'image existante

  final ImagePicker _picker = ImagePicker(); // Initialiser l'ImagePicker
  final PlanteService _planteService = PlanteService(); // Instancier le service

  @override
  void initState() {
    super.initState();
    _loadPlanteData(); // Charger les données de la plante au démarrage
  }

  // Fonction pour charger les données de la plante depuis Firestore
  Future<void> _loadPlanteData() async {
    DocumentSnapshot doc = await widget.planteRef.get();
    Plante plante = Plante.fromDocument(doc); // Créer un objet plante

    // Initialiser les contrôleurs avec les données de la plante
    _nomController.text = plante.nom;
    _nomLocalController.text = plante.nomLocal;
    _descriptionController.text = plante.description;
    _bienfaitsController.text = plante.bienfaits;

    // Vérifier si l'URL de l'image existe
    if (plante.imageUrl.isNotEmpty) {
      _imageUrl = plante.imageUrl; // Assigner l'URL de l'image existante
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

  // Fonction pour modifier la plante dans Firestore
  Future<void> _modifierPlante() async {
    String nom = _nomController.text;
    String nomLocal = _nomLocalController.text;
    String description = _descriptionController.text;
    String bienfaits = _bienfaitsController.text;

    if (nom.isEmpty || nomLocal.isEmpty || description.isEmpty || bienfaits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs et sélectionner une image.')),
      );
      return;
    }

    // Simuler l'URL de l'image
    String imageUrl = _imageFile?.path ?? _imageUrl!; // Utiliser l'URL de l'image existante si aucune nouvelle image n'est sélectionnée

    Plante planteModifiee = Plante(
      nom: nom,
      nomLocal: nomLocal,
      description: description,
      bienfaits: bienfaits,
      imageUrl: imageUrl,
    );

    // Modifier la plante dans Firestore via le service
    await _planteService.updatePlante(widget.planteRef, planteModifiee); // Utiliser la référence de la plante

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Plante modifiée avec succès!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Radius du modal
      ),
      title: Text('Modifier la Plante', style: TextStyle(fontFamily: policePoppins)),
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
                    : _imageUrl != null
                        ? Text('Image existante sélectionnée', style: TextStyle(fontFamily: policePoppins))
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
          onPressed: _modifierPlante, // Appeler la fonction pour modifier la plante
          style: ElevatedButton.styleFrom(
            backgroundColor: couleurPrincipale,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Radius du bouton
            ),
          ),
          child: Text(
            'Modifier',
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