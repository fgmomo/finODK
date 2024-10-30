import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';
import 'package:meditra/sevices/nombreService.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ItemService _itemService = ItemService();
  int _plantesCount = 0;
  int _maladiesCount = 0;
  int _remedesCount = 0;
  int _centresCount = 0;
  int _praticiensCount = 0;
  int _utilisateursCount = 0;
  int _adminsCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchItemCounts(); // Appel pour récupérer les nombres au démarrage
  }

  // Méthode pour récupérer les nombres d'items
 Future<void> _fetchItemCounts() async {
  _plantesCount = await _itemService.getItemCount('plantes');
  _maladiesCount = await _itemService.getItemCount('maladies');
  _remedesCount = await _itemService.getItemCount('remede_maladie');
  _centresCount = await _itemService.getItemCount('centres');
  _praticiensCount = await _itemService.getPraticiensCount(); 
  _utilisateursCount = await _itemService.getVisiteursCount();
  _adminsCount = await _itemService.getItemCount('admin');

  setState(() {}); // Mettre à jour l'état pour rafraîchir l'affichage
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
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
                fontFamily: policeLato,
              ),
            ),
            const SizedBox(height: 20), // Espacement entre le titre et les cartes
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount;

                  // Déterminer le nombre de colonnes en fonction de la largeur de l'écran
                  if (constraints.maxWidth >= 950) {
                    crossAxisCount = 4; // 4 colonnes à partir de 950 pixels
                  } else if (constraints.maxWidth >= 630) {
                    crossAxisCount = 3; // 3 colonnes entre 630 et 950 pixels
                  } else if (constraints.maxWidth >= 350) {
                    crossAxisCount = 2; // 2 colonnes entre 350 et 630 pixels
                  } else {
                    crossAxisCount = 1; // 1 colonne en dessous de 350 pixels
                  }

                  return GridView.count(
                    crossAxisCount: crossAxisCount, // Nombre de cartes par ligne
                    crossAxisSpacing: 20, // Espacement horizontal entre les cartes
                    mainAxisSpacing: 20, // Espacement vertical entre les cartes
                    children: [
                      _buildCard(Icons.eco, _plantesCount, 'Plantes'),
                      _buildCard(Icons.local_pharmacy, _remedesCount, 'Remèdes'),
                      _buildCard(Icons.sick, _maladiesCount, 'Maladies'),
                      _buildCard(Icons.person_search, _praticiensCount, 'Praticiens'),
                      _buildCard(Icons.group, _utilisateursCount, 'Utilisateurs'),
                      _buildCard(Icons.verified_user, _adminsCount, 'Administrateurs'),
                      _buildCard(Icons.local_hospital, _centresCount, 'Centres de Pharmacopées'),
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

  // Widget pour créer une carte
  Widget _buildCard(IconData icon, int count, String name) {
    return Card(
      color: Colors.white, // Couleur de la carte
      elevation: 3, // Ombre de la carte
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Coins arrondis
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centre les éléments
        children: [
          Icon(icon, size: 50, color: couleurPrincipale), // Icône
          const SizedBox(height: 10), // Espacement entre l'icône et le texte
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: policeLato,
            ),
          ),
          const SizedBox(height: 5), // Espacement entre le nombre et le nom
          Text(
            name,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600], // Couleur du texte
              fontFamily: policePoppins,
            ),
          ),
        ],
      ),
    );
  }
}
