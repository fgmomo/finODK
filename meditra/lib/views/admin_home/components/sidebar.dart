import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';
import 'package:meditra/views/auth/login_screen_admin.dart';

class Sidebar extends StatefulWidget {
  final Function(int) onItemSelected;

  Sidebar({required this.onItemSelected});

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  int _hoveredIndex = -1; // Pour savoir quel élément est survolé
  int _selectedIndex = -1; // Pour savoir quel élément est sélectionné

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      // Encapsuler le sidebar dans un autre container pour l'ombre
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Le fond du sidebar est blanc
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Ombre
              spreadRadius: 0, // Élargissement de l'ombre
              blurRadius: 10, // Flou de l'ombre
              offset: Offset(4, 0), // Décalage de l'ombre vers la droite
            ),
          ],
        ),
        child: ListView(
          children: [
            DrawerHeader(
              child: Text(
                'Backoffice Menu',
                style: TextStyle(
                  color: couleurPrincipale,
                  fontSize: 24,
                  fontFamily: policePoppins, // Utilisation de la police Poppins
                ),
              ),
            ),
            _buildListItem(
              index: 0,
              icon: Icons.dashboard,
              text: 'Dashboard',
              onTap: () {
                setState(() {
                  _selectedIndex = 0; // Met à jour l'index sélectionné
                });
                widget.onItemSelected(0);
              },
            ),

            _buildListItem(
              index: 1,
              icon: Icons.eco,
              text: 'Plantes',
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
                widget.onItemSelected(1);
              },
            ),
            _buildListItem(
              index: 2,
              icon: Icons.local_pharmacy,
              text: 'Remèdes',
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
                widget.onItemSelected(2);
              },
            ),
            _buildListItem(
              index: 3,
              icon: Icons.sick,
              text: 'Maladies',
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
                });
                widget.onItemSelected(3);
              },
            ),
            _buildListItem(
              index: 4,
              icon: Icons.person_search,
              text: 'Rémède par maladie',
              onTap: () {
                setState(() {
                  _selectedIndex = 4;
                });
                widget.onItemSelected(4);
              },
            ),
            _buildListItem(
              index: 5,
              icon: Icons.local_hospital,
              text: 'Centres de Pharmacopées',
              onTap: () {
                setState(() {
                  _selectedIndex = 5;
                });
                widget.onItemSelected(5);
              },
            ),

            _buildListItem(
              index: 6,
              icon: Icons.person_search,
              text: 'Praticiens',
              onTap: () {
                setState(() {
                  _selectedIndex = 6;
                });
                widget.onItemSelected(6);
              },
            ),
            _buildListItem(
              index: 7,
              icon: Icons.group,
              text: 'Visiteurs',
              onTap: () {
                setState(() {
                  _selectedIndex = 7; // Met à jour l'index sélectionné
                });
                widget.onItemSelected(7);
              },
            ),
            _buildListItem(
              index: 8,
              icon: Icons.verified_user,
              text: 'Administrateurs',
              onTap: () {
                setState(() {
                  _selectedIndex = 8; // Met à jour l'index sélectionné
                });
                widget.onItemSelected(8);
              },
            ),
            // Barre fine avant le bouton de déconnexion
            Divider(thickness: 1, color: Colors.grey[300]),
            _buildLogoutItem(
              icon: Icons.logout,
              text: 'Déconnexion',
              onTap: () {
                // Afficher une boîte de dialogue de confirmation avant la déconnexion
                _showLogoutConfirmationDialog(context);
              },
            ),
            // Ajoutez d'autres éléments de menu ici
          ],
        ),
      ),
    );
  }

  // Widget pour un élément de la liste principale
  Widget _buildListItem({
    required int index,
    required IconData icon,
    required String text,
    required Function() onTap,
  }) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = -1),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: _hoveredIndex == index || _selectedIndex == index
              ? couleurSecondaire
              : Colors
                  .transparent, // Appliquer couleurSecondaire au hover et à la sélection
          borderRadius: BorderRadius.circular(5), // borderRadius: 5
        ),
        child: ListTile(
          leading: Icon(icon,
              color:
                  couleurPrincipale), // Couleur des icônes : couleurPrincipale
          title: Text(
            text,
            style: TextStyle(
              color: Colors.black, // Texte noir
              fontFamily: policePoppins, // Utilisation de la police Poppins
            ),
          ),
          onTap: onTap, // Action lors du clic
        ),
      ),
    );
  }

  // Widget pour l'élément de déconnexion
  Widget _buildLogoutItem({
    required IconData icon,
    required String text,
    required Function() onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.redAccent
            .withOpacity(0.2), // Couleur de fond différente pour déconnexion
        borderRadius: BorderRadius.circular(5),
      ),
      child: ListTile(
        leading: Icon(icon,
            color: Colors.redAccent), // Icône de déconnexion en rouge
        title: Text(
          text,
          style: TextStyle(
            color: Colors.redAccent,
            fontFamily: policePoppins,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  // Boîte de dialogue de confirmation de déconnexion
  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation de déconnexion"),
          content: Text("Êtes-vous sûr de vouloir vous déconnecter ?"),
          actions: [
            TextButton(
              child: Text("Annuler"),
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
            ),
            ElevatedButton(
              child: Text("Déconnexion"),
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
                _logout(); // Appeler la fonction de déconnexion
              },
            ),
          ],
        );
      },
    );
  }

  // Fonction de déconnexion
  void _logout() async {
    try {
      // Si vous utilisez Firebase Authentication
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreenAdmin()),
      );
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
    }
  }
}
