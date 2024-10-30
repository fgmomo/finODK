import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';
import 'package:meditra/sevices/remede_maladie_service.dart';

class RemedeMaladieModal extends StatefulWidget {
  const RemedeMaladieModal({Key? key}) : super(key: key);

  @override
  State<RemedeMaladieModal> createState() => _RemedeMaladieModalState();
}

class _RemedeMaladieModalState extends State<RemedeMaladieModal> {
  final RemedeMaladieService _service = RemedeMaladieService();
  String? selectedMaladie;
  String? selectedRemede;
  String? _errorMessage; // Pour stocker les messages d'erreur

  List<Map<String, dynamic>> maladies = [];
  List<Map<String, dynamic>> remedes = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Charger les données de maladies et remèdes
  void _loadData() async {
    List<Map<String, dynamic>> maladiesData = await _service.getMaladies();
    List<Map<String, dynamic>> remedesData = await _service.getRemedes();

    setState(() {
      maladies = maladiesData;
      remedes = remedesData;
    });
  }

  // Méthode pour afficher un message d'erreur
  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  // Méthode pour réinitialiser l'erreur
  void _resetError() {
    setState(() {
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Radius du modal
      ),
      title: Text('Associer remède à la maladie',
          style: TextStyle(fontFamily: policePoppins)),
      content: SingleChildScrollView(
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedMaladie,
              decoration: InputDecoration(
                labelText: 'Sélectionner la maladie',
                border: OutlineInputBorder(),
                errorText: _errorMessage != null ? _errorMessage : null, // Affichage de l'erreur
              ),
              items: maladies.map((maladie) {
                return DropdownMenuItem<String>(
                  value: maladie['id'],
                  child: Text(maladie['nom']), // Suppose que le champ est 'nom'
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedMaladie = value;
                });
              },
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedRemede,
              decoration: InputDecoration(
                labelText: 'Sélectionner le remède',
                border: OutlineInputBorder(),
                errorText: _errorMessage != null ? _errorMessage : null, // Affichage de l'erreur
              ),
              items: remedes.map((remede) {
                return DropdownMenuItem<String>(
                  value: remede['id'],
                  child: Text(remede['nom']), // Suppose que le champ est 'nom'
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedRemede = value;
                });
              },
            ),
            SizedBox(height: 10),
            if (_errorMessage != null) // Afficher l'erreur en dessous des champs si elle existe
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
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
          onPressed: selectedMaladie != null && selectedRemede != null
              ? () async {
                  _resetError(); // Réinitialiser l'erreur avant la tentative d'association
                  try {
                    await _service.associerRemedeMaladie(
                        selectedRemede!, selectedMaladie!);
                    // Afficher un message de succès avec ScaffoldMessenger
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Association réussie.')),
                    );
                    Navigator.of(context).pop();
                  } catch (e) {
                    // Afficher une erreur dans l'UI
                    _showError(e.toString());
                    // Afficher l'erreur avec ScaffoldMessenger
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur : $e')),
                    );
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: couleurPrincipale,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Radius du bouton
            ),
          ),
          child: Text(
            'Associer',
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
