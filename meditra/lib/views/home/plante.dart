  import 'package:flutter/material.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:meditra/config/config.dart';
  import 'package:meditra/views/home/detail_plante.dart';
import 'package:meditra/views/home/remede.dart';
  import 'package:shimmer/shimmer.dart'; 

  class PlanteScreen extends StatefulWidget {
    const PlanteScreen({super.key});

    @override
    State<PlanteScreen> createState() => _PlanteScreenState();
  }

class _PlanteScreenState extends State<PlanteScreen> {
  List<Map<String, dynamic>> filteredPlantes = [];
  List<Map<String, dynamic>> allPlantes = [];

  Future<void> _fetchPlantes() async {
    final QuerySnapshot result =
        await FirebaseFirestore.instance.collection('plantes').get();
    allPlantes = result.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    filteredPlantes = allPlantes;
  }

  void _searchPlantes(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredPlantes = allPlantes;
      } else {
        final suggestions = allPlantes.where((plante) {
          final planteName = plante['nom']?.toLowerCase() ?? '';
          final input = query.toLowerCase();
          return planteName.contains(input);
        }).toList();
        filteredPlantes = suggestions;
      }
    });
  }

  Widget _buildShimmerEffect() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(15),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.75,
      ),
      itemCount: 6, // Nombre d'éléments de shimmer
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200], // Couleur de fond pour le shimmer
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    color: Colors.grey[200], // Couleur de fond pour le shimmer
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    height: 20, // Hauteur fixe pour le texte
                    color: Colors.grey[200], // Couleur de fond pour le shimmer
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text(
          'Liste des Plantes',
          style: TextStyle(
            fontFamily: policeLato,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.black,
            height: 0.2,
          ),
        ),
      ),
      
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SizedBox(height: 6),
            ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RemedeScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.local_pharmacy, color: Colors.white),
                    label: const Text(
                      'Voir les rémèdes',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: couleurPrincipale,
                      padding: const EdgeInsets.symmetric(
                          vertical: 13, horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
             const Divider(
              color: Colors.grey,
              thickness: 0.5,
              indent: 16,
              endIndent: 18,
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TextField(
                  onChanged: _searchPlantes,
                  style: const TextStyle(
                    fontFamily: policeLato,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Rechercher une plante...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search, color: Colors.black),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                  ),
                ),
              ),
            ),
            FutureBuilder<void>(
              future: _fetchPlantes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  print("Loading..."); // Pour déboguer
                  return _buildShimmerEffect(); // Utilisation du shimmer pendant le chargement
                } else if (snapshot.hasError) {
                  print("Error: ${snapshot.error}"); // Pour déboguer
                  return const Center(child: Text('Erreur de chargement'));
                } else {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(15),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: filteredPlantes.length,
                    itemBuilder: (context, index) {
                      final plante = filteredPlantes[index];
                      bool isLoadingImage = true;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPlanteScreen(
                                nomPlante: plante['nom']!,
                                nomLocal: plante['nom_local'] ?? '',
                                imagePlante: plante['image']!,
                                description: plante['description'],
                                bienfaits: plante['bienfaits'],
                              ),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: Colors.white,
                          elevation: 1.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    if (isLoadingImage)
                                      Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200], // Couleur de fond pour le shimmer
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    Image.network(
                                      plante['image']!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      loadingBuilder: (BuildContext context, Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) {
                                          // Image chargée
                                          isLoadingImage = false;
                                          return child;
                                        } else {
                                          // Pendant le chargement, shimmer continue
                                          return const SizedBox();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  plante['nom']!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: policePoppins,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
       ),
    );
  }
}