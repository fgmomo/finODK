import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';

class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white, // Couleur de l'en-tête
        // boxShadow supprimé pour éviter l'ombre
      ),
      child: Row(
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
          // Text('Backoffice Header', style: TextStyle(color: Colors.black, fontSize: 20)),
          Spacer(),
          // Nom de l'utilisateur avec photo de profil
          Row(
            children: [
                CircleAvatar(
                radius: 18, // Taille de la photo de profil
                backgroundImage: AssetImage('assets/prof.jpg'), // Remplacer par l'image de profil
                backgroundColor: Colors.grey[200], // Couleur de fond si pas d'image
              ),
               SizedBox(width: 10), // Espace entre le nom et la photo
              Text(
                'Kontere Tienou',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
             
            
            ],
          ),
        ],
      ),
    );
  }
}
