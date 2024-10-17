import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';
import 'package:meditra/sevices/centres_pharma_service.dart';
import 'package:meditra/views/home/DetailsCentre.dart';

class CentrePharmasScreen extends StatefulWidget {
  const CentrePharmasScreen({super.key});

  @override
  State<CentrePharmasScreen> createState() => _CentrePharmasScreenState();
}

class _CentrePharmasScreenState extends State<CentrePharmasScreen> {
  List<Map<String, dynamic>> centres = []; // Stocker les centres récupérés
  bool isLoading = true; // Pour afficher un indicateur de chargement
  String searchQuery = ""; // Pour stocker la requête de recherche

  // Initialiser le service
  final CentreService centreService = CentreService();

  @override
  void initState() {
    super.initState();
    _loadCentres();
  }

  // Méthode pour récupérer les centres
  Future<void> _loadCentres() async {
    try {
      List<Map<String, dynamic>> loadedCentres =
          await centreService.recupererCentresPharmacopee();
      setState(() {
        centres = loadedCentres;
        isLoading = false;
      });
    } catch (e) {
      print("Erreur lors du chargement des centres: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Méthode pour vérifier si un centre correspond à la recherche
  bool _matchesSearchQuery(Map<String, dynamic> centre) {
    return centre['nom'].toLowerCase().contains(searchQuery.toLowerCase()) ||
        centre['telephone'].toString().contains(searchQuery) ||
        centre['adresse'].toLowerCase().contains(searchQuery.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Centres de Pharmacopée'),
        backgroundColor:
            Colors.white // Couleur personnalisée pour app bar
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Indicateur de chargement
          : Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  // Barre de recherche
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher par nom,adresse..,',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery =
                            value; // Mettre à jour la requête de recherche
                      });
                    },
                  ),
                  const SizedBox(height: 35),
                  // Titre de la liste
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Liste des centres de pharmacopées',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: policeLato,
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      itemCount: centres.length,
                      itemBuilder: (context, index) {
                        final centre = centres[index];

                        // Filtrer les centres selon la recherche
                        if (!_matchesSearchQuery(centre)) {
                          return Container(); // Ne pas afficher cet élément
                        }

                        return GestureDetector(
                          onTap: () {
                          
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailsCentre(centre: centre),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 1,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment
                                    .center, // Centrer le contenu
                                children: [
                                  // Image du centre à gauche
                                  ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomLeft: Radius.circular(8),
                                    ),
                                    child: Image.network(
                                      centre['image'],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Informations à droite
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment
                                          .center, // Centrer verticalement
                                      children: [
                                        // Nom du centre avec une icône
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              centre['nom'],
                                              style: const TextStyle(
                                                fontSize: 23,
                                                fontFamily: policeLato,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.remove_red_eye_sharp),
                                              color: couleurPrincipale,
                                              onPressed: () {
                                                // Action pour afficher les détails
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),

                                        // Téléphone avec icône
                                        Row(
                                          children: [
                                            const Icon(
                                                Icons.location_on_outlined,
                                                color: couleurPrincipale),
                                            const SizedBox(width: 2),
                                            Text(
                                              centre['adresse'],
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16,
                                                fontFamily: policePoppins,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
