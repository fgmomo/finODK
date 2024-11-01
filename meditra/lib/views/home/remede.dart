import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:meditra/config/config.dart';
import 'package:meditra/views/home/RemedeListScreen.dart';

class RemedeScreen extends StatefulWidget {
  const RemedeScreen({Key? key}) : super(key: key);
  @override
  _RemedeScreenState createState() => _RemedeScreenState();
}

class _RemedeScreenState extends State<RemedeScreen> {
  List<Map<String, String>> filteredMaladies = [];
  List<Map<String, String>> allMaladies = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Appel à Firestore pour récupérer les données
    _fetchMaladies();
    searchController.addListener(_filterMaladies);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

// Fonction pour récupérer les maladies depuis Firestore
  Future<void> _fetchMaladies() async {
    try {
      // Accès à la collection 'maladies' dans Firestore
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('maladies').get();

      // Extraction des documents et ajout dans la liste 'allMaladies'
      allMaladies = querySnapshot.docs.map((doc) {
        return {
          'nom': doc['nom'].toString(), // Conversion explicite en String
          'description':
              doc['description'].toString(), // Conversion explicite en String
        };
      }).toList();

      // Initialement, toutes les maladies sont affichées
      setState(() {
        filteredMaladies = allMaladies;
      });
    } catch (e) {
      print('Erreur lors de la récupération des maladies : $e');
    }
  }

  // Fonction pour filtrer les maladies selon la recherche
  void _filterMaladies() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredMaladies = allMaladies.where((maladie) {
        String nom = maladie['nom']!.toLowerCase();
        String description = maladie['description']!.toLowerCase();
        return nom.contains(query) || description.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text(
          'Remèdes',
          style: TextStyle(
            fontFamily: policeLato,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        // elevation: 1,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.black,
            height: 0.2,
          ),
        ),
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher une maladie',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: filteredMaladies.length,
              itemBuilder: (context, index) {
                final maladie = filteredMaladies[index];
                return _buildMaladieCard(maladie, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaladieCard(Map<String, String> maladie, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 5, // Élévation pour un effet d'ombre
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0), // Coins arrondis
      ),
      child: InkWell(
        onTap: () {
          // Affiche le modal ou redirige
          _showDescriptionDialog(
              context, maladie['nom'], maladie['description']);
        },
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            gradient: LinearGradient(
              colors: [
                couleurPrincipale,
                const Color.fromARGB(255, 2, 39, 4)
              ], // Dégradé de couleur
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              // Icône décorative à gauche
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.local_hospital_rounded,
                  color: couleurPrincipale,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              // Informations sur la maladie
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      maladie['nom'] ?? '',
                      style: const TextStyle(
                        fontFamily: policeLato,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      maladie['description'] ?? '',
                      maxLines: 2, // Limiter la description à 2 lignes
                      overflow:
                          TextOverflow.ellipsis, // Texte tronqué si trop long
                      style: const TextStyle(
                        fontFamily: policePoppins,
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              // Icône flèche pour plus d'infos
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

// Affiche une boîte de dialogue avec la description complète de la maladie
  void _showDescriptionDialog(
      BuildContext context, String? nom, String? description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            nom ?? '',
            style: const TextStyle(
              fontFamily: policePoppins,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            description ?? '',
            style: const TextStyle(
              fontFamily: policePoppins,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le modal
              },
              child: const Text(
                'Fermer',
                style: TextStyle(
                  fontFamily: policePoppins,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme d'abord le modal
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RemedeListScreen(
                      nomMaladie: nom ?? '',
                      descriptionMaladie: description ?? '',
                    ),
                  ),
                );
              },
              child: const Text(
                'Voir les remèdes',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: policePoppins,
                  fontSize: 16,
                  color: couleurPrincipale,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
