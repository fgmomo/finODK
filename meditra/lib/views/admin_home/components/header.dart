import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';
import 'package:meditra/sevices/admin_service.dart';

class Header extends StatefulWidget {
  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  final AdminService _adminService = AdminService();
  String? _adminFullName; // Stockage du nom complet de l'admin

  @override
  void initState() {
    super.initState();
    _fetchAdminName(); // Récupération du nom de l'admin lors de l'initialisation
  }

  Future<void> _fetchAdminName() async {
    var adminData = await _adminService.recupererAdminConnecte();
    if (adminData != null) {
      setState(() {
        _adminFullName = "${adminData['firstName']} ${adminData['lastName']}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Couleur de fond de l'AppBar
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3), // Couleur de l'ombre
            spreadRadius: 0, // Élargissement de l'ombre
            blurRadius: 8, // Flou de l'ombre
            offset: Offset(0, 4), // Déplacement de l'ombre vers le bas
          ),
        ],
      ),
      child: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0, // Désactiver l'élévation de l'AppBar
        title: Row(
          children: [
            // Icône menu cliquable uniquement pour petits écrans (Drawer)
            if (Scaffold.of(context).hasDrawer) // Vérifie si le Drawer est disponible
              IconButton(
                icon: Icon(Icons.menu, color: couleurPrincipale),
                onPressed: () {
                  Scaffold.of(context).openDrawer(); // Ouvre le Drawer
                },
              ),
            SizedBox(width: 10),
          ],
        ),
        actions: [
          // Nom de l'utilisateur avec icône
          Row(
            children: [
              Icon(
                Icons.person, // Icône à la place de CircleAvatar
                size: 30, // Taille de l'icône
                color: couleurPrincipale, // Couleur de l'icône
              ),
              SizedBox(width: 10), // Espace entre l'icône et le nom

              // Affichage du nom de l'admin
              _adminFullName == null
                  ? CircularProgressIndicator() // Loader en attendant le nom
                  : Text(
                      _adminFullName ?? 'Nom indisponible',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: policePoppins,
                      ),
                    ),
              SizedBox(width: 10), // Espace à droite du nom
            ],
          ),
        ],
      ),
    );
  }
}
