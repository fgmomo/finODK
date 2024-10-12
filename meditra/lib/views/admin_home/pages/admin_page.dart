import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';
import 'package:meditra/sevices/authadmin_service.dart';
import 'package:meditra/views/admin_home/pages/add_admin_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final AuthAdminService adminService = AuthAdminService();
  List<Map<String, String>> admins = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdmins(); // Charger les administrateurs au démarrage
  }

  Future<void> _loadAdmins() async {
    try {
      admins = await adminService.getAllAdmins(); // Correction du nom de la méthode
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur de chargement : $e')));
    } finally {
      setState(() {
        isLoading = false; // Mettre à jour l'état de chargement
      });
    }
  }

  Future<void> _addAdmin(String nom, String prenom, String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String userId = userCredential.user!.uid;
      CollectionReference adminCollection = FirebaseFirestore.instance.collection('admin');
      await adminCollection.doc(userId).set({
        'firstName': prenom,
        'lastName': nom,
        'email': email,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Administrateur ajouté avec succès')));
      _loadAdmins(); // Recharger la liste des administrateurs après l'ajout
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de l\'ajout : $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
         appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 245, 245, 245),
        title: Row(
          children: [
            Text('Tableau des Administrateurs',
                style: TextStyle(fontFamily: policePoppins)),
            SizedBox(width: 10),
            TextButton(
              onPressed: () {
                 showDialog(
                         context: context,
                         builder: (BuildContext context) {
                           return AddAdminModal(onAddAdmin: _addAdmin);
                         },
                       );
              },
              style: TextButton.styleFrom(
                backgroundColor: couleurPrincipale,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              child: Text(
                'Ajouter',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: policePoppins,
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // SizedBox(height: 20),
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(3),
                    3: FlexColumnWidth(1),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      children: [
                        _buildTableHeader('Nom'),
                        _buildTableHeader('Prénom'),
                        _buildTableHeader('Email'),
                        _buildTableHeader('Actions'),
                      ],
                    ),
                    ...admins.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, String> admin = entry.value;
                      return TableRow(
                        decoration: BoxDecoration(
                          color: index.isEven ? Colors.white : Colors.grey[100],
                        ),
                        children: [
                          _buildTableCell(admin['nom'] ?? 'Nom indisponible'),
                          _buildTableCell(admin['prenom'] ?? 'Prénom indisponible'),
                          _buildTableCell(admin['email'] ?? 'Email indisponible'),
                          _buildActionIcons(admin['userId'] ?? ''),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          fontFamily: policePoppins,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontFamily: policePoppins,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildActionIcons(String userId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.edit, color: Colors.blue),
          onPressed: () {
            // Ajouter la logique de mise à jour ici
          },
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            // Ajouter la logique de suppression ici
          },
        ),
      ],
    );
  }
}
