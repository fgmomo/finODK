import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Fond gris
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre du Dashboard
            Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20), // Espace entre le titre et les cartes
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Nombre de colonnes basé sur la largeur disponible
                  int crossAxisCount = (constraints.maxWidth > 600) ? 3 : 2;

                  return GridView.count(
                    crossAxisCount: crossAxisCount, // Nombre de colonnes dynamique
                    crossAxisSpacing: 20, // Espace horizontal entre les cartes
                    mainAxisSpacing: 20, // Espace vertical entre les cartes
                    children: [
                      _buildCard('Nombre d\'Utilisateurs', Icons.person, 120),
                      _buildCard('Nombre de Commandes', Icons.shopping_cart, 75),
                      _buildCard('Chiffre d\'Affaires', Icons.monetization_on, 10000),
                      _buildCard('Feedback', Icons.feedback, 50),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour construire une carte d'élément
  Widget _buildCard(String title, IconData icon, int count) {
    return Card(
      color: Colors.white,
      elevation: 5, // Ombre de la carte
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Coins arrondis
      ),
      child: Container(
        height: 120, // Ajustement de la hauteur de la carte
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Padding réduit
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre en haut à gauche
            Text(
              title,
              style: TextStyle(
                fontSize: 14, // Taille du texte réduite
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8), // Espacement réduit entre le titre et l'icône
            Row(
              children: [
                // Icône avec fond circulaire gris
                Container(
                  padding: EdgeInsets.all(6), // Padding autour de l'icône réduit
                  decoration: BoxDecoration(
                    color: Colors.grey[300], // Fond gris circulaire
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: couleurPrincipale), // Taille de l'icône réduite
                ),
                SizedBox(width: 8), // Espace entre l'icône et le nombre
                // Nombre à droite de l'icône
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 18, // Taille du nombre réduite
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
