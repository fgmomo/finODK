import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';
import 'package:meditra/sevices/maladie_service.dart';

class MaladieAddModal extends StatefulWidget {
  final MaladieService maladieService; // Référence correcte du service

  const MaladieAddModal({Key? key, required this.maladieService}) : super(key: key);

  @override
  State<MaladieAddModal> createState() => _MaladieAddModalState();
}

class _MaladieAddModalState extends State<MaladieAddModal> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Fonction pour ajouter la maladie dans Firestore
  Future<void> _ajouterMaladie() async {
    print("Tentative d'ajout d'une maladie"); // Pour le débogage

    String nom = _nomController.text;
    String description = _descriptionController.text;

    if (nom.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    try {
      // Utilisation de l'instance maladieService passée par le widget parent
      await widget.maladieService.addMaladie(nom, description);

      if (mounted) {
        Navigator.of(context).pop(); // Ferme le modal
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maladie ajoutée avec succès!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout de la maladie: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Radius du modal
      ),
      title: Text('Ajouter une maladie',
          style: TextStyle(fontFamily: policePoppins)),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _nomController,
              decoration: InputDecoration(
                labelText: 'Nom de la maladie',
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
          child: Text('Annuler', style: TextStyle(fontFamily: policePoppins)),
        ),
        ElevatedButton(
          onPressed: _ajouterMaladie, // Appel de la fonction pour ajouter la maladie
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
