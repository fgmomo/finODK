import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditra/sevices/maladie_service.dart'; // Assurez-vous d'importer correctement votre service

class EditMaladieModal extends StatefulWidget {
  final DocumentReference maladieRef; // Référence de la maladie à modifier

  const EditMaladieModal({Key? key, required this.maladieRef}) : super(key: key);

  @override
  State<EditMaladieModal> createState() => _EditMaladieModalState();
}

class _EditMaladieModalState extends State<EditMaladieModal> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
 
  final MaladieService _maladieService = MaladieService(); // Instancier le service

  @override
  void initState() {
    super.initState();
    _loadMaladieData(); // Charger les données de la maladie au démarrage
  }

  // Fonction pour charger les données de la maladie depuis Firestore
  Future<void> _loadMaladieData() async {
    DocumentSnapshot doc = await widget.maladieRef.get();
    Maladie maladie = Maladie.fromDocument(doc);

    // Initialiser les contrôleurs avec les données de la maladie
    _nomController.text = maladie.nom;
    _descriptionController.text = maladie.description;
  }

  // Fonction pour modifier la maladie dans Firestore
  Future<void> _modifierMaladie() async {
    String nom = _nomController.text;
    String description = _descriptionController.text;

    if (nom.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      return;
    }

    // Créer un objet Maladie modifié
    Maladie maladieModifiee = Maladie(
      nom: nom,
      description: description,
    );

    // Modifier la maladie dans Firestore via le service
    await _maladieService.updateMaladie(widget.maladieRef, maladieModifiee); // Utiliser la référence de la maladie

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Maladie modifiée avec succès!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Text('Modifier la Maladie'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _nomController,
              decoration: InputDecoration(
                labelText: 'Nom de la Maladie',
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
          onPressed: _modifierMaladie, // Appeler la fonction pour modifier la maladie
          child: Text('Modifier'),
        ),
      ],
    );
  }
}
