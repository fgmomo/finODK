import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';
import 'package:meditra/sevices/consultation_service.dart';
import 'package:meditra/sevices/maladie_service.dart';
import 'package:meditra/sevices/plante_service.dart';
import 'package:meditra/views/home/centres.dart';
import 'package:meditra/views/home/consultation_approuve.dart';
import 'package:meditra/views/home/detail_plante.dart';
import 'package:meditra/views/home/remede.dart';
import 'package:meditra/views/home/visiteur_consultation_all.dart';
import 'package:meditra/views/home_praticien/DiscussionPage.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VisitorHomeScreen extends StatefulWidget {
  const VisitorHomeScreen({Key? key}) : super(key: key);

  @override
  State<VisitorHomeScreen> createState() => _VisitorHomeScreenState();
}

class _VisitorHomeScreenState extends State<VisitorHomeScreen> {
  final ConsultationService _consultationService = ConsultationService();
  Future<Map<String, dynamic>?>? _futureConsultation;
  final MaladieService _maladieService = MaladieService();
  Future<List<Maladie>>? _futureMaladies; // Liste de maladies
  List<Map<String, dynamic>> filteredPlantes = [];
  List<Map<String, dynamic>> allPlantes = [];

  // fetch all the plantes here
  Future<void> _fetchPlantes() async {
    final QuerySnapshot result =
        await FirebaseFirestore.instance.collection('plantes').get();
    allPlantes =
        result.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
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

//----------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    // Appel pour récupérer la dernière consultation approuvée
    _futureConsultation =
        _consultationService.fetchDerniereConsultationAppVisiteur();
    _futureMaladies = _maladieService.fetchMaladies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenue,',
              style: TextStyle(
                fontSize: 22,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: policeLato,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Aoua', // Nom du visiteur
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications,
              color: couleurPrincipale,
              size: 35,
            ),
            onPressed: () {},
            padding: EdgeInsets.all(10),
            tooltip: 'Notifications',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.black,
            height: 0.2,
          ),
        ),
      ),
      //----------------------------------------------------------------
      backgroundColor: Colors.white,
      //--- body

      body: Padding(
        padding: const EdgeInsets.all(20.3),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Ma consultation actuelle',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: policeLato,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VisiteurConsultationAllScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Voir tout',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: policeLato,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),

              // Utilisation d'un FutureBuilder pour récupérer et afficher la consultation
              FutureBuilder<Map<String, dynamic>?>(
                // Wrap InkWell ici
                future: _futureConsultation,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child:
                            CircularProgressIndicator()); // Loader pendant le chargement
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur : ${snapshot.error}'));
                  } else if (snapshot.hasData && snapshot.data != null) {
                    var consultation = snapshot.data!;
                    String reference = consultation['reference'];
                    // Rendre la carte cliquable avec InkWell
                    return InkWell(
                      onTap: () {
                        // Redirige vers la page de discussion
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DiscussionPage(
                              discussionId:
                                  reference, // Utilise la référence de la consultation comme ID de discussion
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [
                              couleurPrincipale,
                              Color.fromARGB(255, 2, 39, 4)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipOval(
                                  child: consultation['profileImageUrl'] != null
                                      ? Image.network(
                                          consultation['profileImageUrl'],
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.asset(
                                              'assets/prof.jpg',
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        )
                                      : Image.asset(
                                          'assets/prof.jpg',
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        consultation['praticien'],
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontFamily: policeLato,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Statut : Approuvé',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Divider(color: Colors.white, thickness: 1),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        color: Colors.white),
                                    SizedBox(width: 5),
                                    Text(
                                      '${consultation['crenau_date']}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: policePoppins,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.access_time,
                                        color: Colors.white),
                                    SizedBox(width: 5),
                                    Text(
                                      '${consultation['crenau_heures']}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: policePoppins,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    // Affichage du message dans une carte vide
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [
                            couleurPrincipale,
                            Color.fromARGB(255, 2, 39, 4)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Aucune consultation approuvée trouvée.',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontFamily: policeLato,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          Icon(Icons.event_note, color: Colors.white, size: 40),
                        ],
                      ),
                    );
                  }
                },
              ),
              ////////////////////////////////////////////////////////////////
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Explorer les maladies',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: policeLato,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RemedeScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Voir tout',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: policeLato,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
////////////////////////////////////////////////////////////////
              FutureBuilder<List<Maladie>>(
                future: _futureMaladies, // Récupérer la liste des maladies
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child:
                            CircularProgressIndicator()); // Loader pendant le chargement
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur : ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    var maladies = snapshot.data!;
                    return SizedBox(
                      height: 100,
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 0), // Supprimez l'espace à gauche
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: maladies.length, // Nombre de maladies
                          itemBuilder: (context, index) {
                            return Container(
                              width: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          couleurSecondaire, // Couleur de fond de l'icône
                                    ),
                                    padding: EdgeInsets.all(15),
                                    child: Icon(
                                      Icons
                                          .local_hospital_rounded, // Icône représentant la maladie
                                      size: 30,
                                      color:
                                          couleurPrincipale, // Couleur de l'icône
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    maladies[index].nom, // Nom de la maladie
                                    style: TextStyle(
                                      color: Colors.black, // Couleur du texte
                                      fontFamily: policePoppins,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  } else {
                    return Center(child: Text('Aucune maladie trouvée.'));
                  }
                },
              ),

              //----------------------------------------------------------------
              // Section Explorez nos plantes
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Nos plantes',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: policeLato,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CentrePharmasScreen(),
                        ),
                      );
                      
                    },
                    child: Text(
                      'Voir tout',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: policeLato,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),

              //----------------------------------------------------------------
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
      return SizedBox(
        height: 180, // Ajuste la hauteur en fonction de la taille des cartes
        child: ListView.builder(
          scrollDirection: Axis.horizontal, // Défilement horizontal
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
              child: Container(
                width: 150, // Ajuste la largeur des cartes
                margin: const EdgeInsets.symmetric(horizontal: 10), // Espace entre les cartes
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
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            Image.network(
                              plante['image']!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  isLoadingImage = false;
                                  return child;
                                } else {
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
              ),
            );
          },
        ),
      );
    }
  },
)
            ],
          ),
        ),
      ),
    );
  }
}
