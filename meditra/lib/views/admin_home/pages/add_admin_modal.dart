import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';
class AddAdminModal extends StatefulWidget {
  final Future<void> Function(String nom, String prenom, String email, String password) onAddAdmin;

  const AddAdminModal({Key? key, required this.onAddAdmin}) : super(key: key);

  @override
  _AddAdminModalState createState() => _AddAdminModalState();
}

class _AddAdminModalState extends State<AddAdminModal> {
  final _formKey = GlobalKey<FormState>();
  String _nom = '';
  String _prenom = '';
  String _email = '';
  String _password = '';
  String _errorMessage = ''; // Variable pour stocker les erreurs

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Ajouter un administrateur'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Afficher l'erreur en haut du modal
            if (_errorMessage.isNotEmpty)
              Container(
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.only(bottom: 10),
                color: Colors.red[100], // Couleur de fond pour l'erreur
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder( // Bordure fermée
                  borderRadius: BorderRadius.circular(10), // Radius des coins
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12), // Paddings
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un nom';
                }
                return null;
              },
              onSaved: (value) {
                _nom = value!;
              },
            ),
            SizedBox(height: 10), // Espacement entre les champs
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Prénom',
                border: OutlineInputBorder( // Bordure fermée
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un prénom';
                }
                return null;
              },
              onSaved: (value) {
                _prenom = value!;
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un email';
                }
                return null;
              },
              onSaved: (value) {
                _email = value!;
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
              obscureText: true, // Masquer le mot de passe
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un mot de passe';
                }
                return null;
              },
              onSaved: (value) {
                _password = value!;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Ferme le modal
          },
          child: Text(
            'Annuler',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: couleurPrincipale,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            setState(() {
              _errorMessage = ''; // Réinitialiser le message d'erreur
            });

            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              try {
                await widget.onAddAdmin(_nom, _prenom, _email, _password); // Attendre la réponse
                Navigator.of(context).pop(); // Fermer le modal si succès
              } catch (e) {
                setState(() {
                  _errorMessage = e.toString(); // Afficher l'erreur dans le modal
                });
              }
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: couleurPrincipale, // Couleur du texte
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20), // Padding du bouton
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5), // Définit un radius circulaire de 5
            ),
          ),
          child: Text(
            'Ajouter',
            style: TextStyle(
              fontFamily: policePoppins,
            ),
          ),
        ),
      ],
    );
  }
}