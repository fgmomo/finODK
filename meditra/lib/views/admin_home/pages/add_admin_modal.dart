import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meditra/sevices/admin_service.dart';
class AddAdminModal extends StatefulWidget {
 final VoidCallback onAdminAdded; // Déclarez le paramètre de callback
  const AddAdminModal({Key? key, required this.onAdminAdded}) : super(key: key);
  @override
  _AddAdminModalState createState() => _AddAdminModalState();
}

class _AddAdminModalState extends State<AddAdminModal> {
  final _formKey = GlobalKey<FormState>();
  final AdminService _adminService = AdminService();

  String _nom = '';
  String _prenom = '';
  String _email = '';
  String _password = '';
  String _errorMessage = '';

void onAdminAdded() {
    // Logique à exécuter après l'ajout d'un administrateur
    // Par exemple, vous pouvez mettre à jour une liste d'administrateurs, afficher un message, etc.
    print("Un administrateur a été ajouté avec succès !");
    // Vous pouvez aussi appeler setState si cela concerne l'état de l'UI
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Ajouter un administrateur'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_errorMessage.isNotEmpty)
              Container(
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.only(bottom: 10),
                color: Colors.red[100],
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un nom';
                }
                return null;
              },
              onSaved: (value) => _nom = value ?? '',
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Prénom',
                border: OutlineInputBorder(
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
              onSaved: (value) => _prenom = value ?? '',
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
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Veuillez entrer un email valide';
                }
                return null;
              },
              onSaved: (value) => _email = value ?? '',
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
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un mot de passe';
                }
                if (value.length < 6) {
                  return 'Le mot de passe doit contenir au moins 6 caractères';
                }
                return null;
              },
              onSaved: (value) => _password = value ?? '',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
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
            if (_formKey.currentState?.validate() ?? false) {
              _formKey.currentState?.save();
              try {
                await _adminService.ajouterAdmin(
                  email: _email,
                  password: _password,
                  nom: _nom,
                  prenom: _prenom,
                );
                Navigator.of(context).pop();
                 onAdminAdded(); 
              } catch (e) {
                setState(() {
                  _errorMessage = e.toString();
                });
              }
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: couleurPrincipale,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
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
