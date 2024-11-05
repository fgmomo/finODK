import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';
import 'package:meditra/sevices/centres_pharma_service.dart';
import 'package:meditra/sevices/consultation_service.dart';
import 'package:meditra/sevices/full_name_service.dart';
import 'package:meditra/sevices/maladie_service.dart';

import 'package:meditra/views/home/DetailsCentre.dart';
import 'package:meditra/views/home/RemedeListScreen.dart';
import 'package:meditra/views/home/centres.dart';

import 'package:meditra/views/home/detail_plante.dart';
import 'package:meditra/views/home/plante.dart';
import 'package:meditra/views/home/remede.dart';

import 'package:meditra/views/home_praticien/DiscussionPage.dart';
import 'package:meditra/views/home_praticien/praticien_consultation.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PraticienHomeScreen extends StatefulWidget {
  const PraticienHomeScreen({Key? key}) : super(key: key);

  @override
  State<PraticienHomeScreen> createState() => _PraticienHomeScreenState();
}

class _PraticienHomeScreenState extends State<PraticienHomeScreen> {
  final ConsultationService _consultationService = ConsultationService();
  Future<Map<String, dynamic>?>? _futureConsultation;
  final MaladieService _maladieService = MaladieService();
  Future<List<Maladie>>? _futureMaladies; // Liste de maladies
  List<Map<String, dynamic>> filteredPlantes = [];
  List<Map<String, dynamic>> allPlantes = [];
  Future<void>? _futurePlantes;
  Future<void>? _futureCentres;

  List<Map<String, dynamic>> centres = []; // Stocker les centres récupérés
  bool isLoading = true; // Pour afficher un indicateur de chargement
  String searchQuery = ""; // Pour stocker la requête de recherche

  // Initialiser le service
  final CentreService centreService = CentreService();
  final FullNameService _fullName = FullNameService();
 String? _praFullName; 

  Future<void> _fetchPraticienName() async {
    var praData = await _fullName.recupererPraticienConnecte();
    if (praData != null) {
      setState(() {
        _praFullName = "${praData['firstName']} ${praData['lastName']}";
      });
    }
  }

  // fetch all the plantes here
  Future<void> _fetchPlantes() async {
    final QuerySnapshot result =
        await FirebaseFirestore.instance.collection('plantes').get();
    allPlantes =
        result.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    filteredPlantes = allPlantes;
  }

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

//----------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    // Appel pour récupérer la dernière consultation approuvée
    _futureConsultation =
        _consultationService.fetchDerniereConsultationAppPraticien();
    _futureMaladies = _maladieService.fetchMaladies();
    _futurePlantes = _fetchPlantes();
    _futureCentres = _loadCentres();
    _fetchPraticienName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenue,',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: policeLato,
              ),
            ),
            SizedBox(height: 2),
            Text(
              '${_praFullName}', // Nom du visiteur
              style: TextStyle(
                fontFamily: policePoppins,
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ],
        ),
      bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Divider(
              color: Color.fromARGB(255, 233, 233, 233),
              height: 0.1,
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
                      'Ma consultation en cours',
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
                          builder: (context) => PraticienConsultationScreen()
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
                      // Shimmer effect pendant le chargement
                      child: Shimmer.fromColors(
                        baseColor:
                            Colors.grey[300]!, // Couleur de base du shimmer
                        highlightColor:
                            Colors.grey[100]!, // Couleur de surbrillance
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ); // Loader pendant le chargement
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
                                  child: consultation['visiteur_photo'] != null
                                      ? Image.network(
                                          consultation['visiteur_photo'],
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
                                          '${consultation['visiteur_prenom']} ${consultation['visiteur_nom']}',
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
                    // Afficher un effet Shimmer pendant le chargement
                    return SizedBox(
                      height: 100,
                      child: Padding(
                        padding: EdgeInsets.only(left: 0),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 5, // Nombre d'éléments Shimmer à afficher
                          itemBuilder: (context, index) {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: 100,
                                margin: EdgeInsets.symmetric(horizontal: 8.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey[
                                            300], // Placeholder pour l'icône
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Container(
                                      width: 60,
                                      height: 10,
                                      color: Colors.grey[
                                          300], // Placeholder pour le texte
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur : ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    var maladies = snapshot.data!;
                    return SizedBox(
                      height: 100,
                      child: Padding(
                        padding: EdgeInsets.only(left: 0),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: maladies.length, // Nombre de maladies
                          itemBuilder: (context, index) {
                           return Container(
  width: 100,
  height: 100, // Gardez cette hauteur pour le conteneur
  child: SingleChildScrollView(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            print("Icône cliquée !");
            _showDescriptionDialog(
              context,
              maladies[index].nom,
              maladies[index].description,
            );
          },
          borderRadius: BorderRadius.circular(50),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: couleurSecondaire,
            ),
            padding: EdgeInsets.all(15),
            child: Icon(
              Icons.local_hospital_rounded,
              size: 30,
              color: couleurPrincipale,
            ),
          ),
        ),
        SizedBox(height: 5),
        Text(
          maladies[index].nom,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          style: TextStyle(
            color: Colors.black,
            fontFamily: policePoppins,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
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
                          builder: (context) => PlanteScreen(),
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
                future: _futurePlantes,
                builder: (context, snapshot) {
                  return SizedBox(
                    height:
                        180, // Ajuste la hauteur en fonction de la taille des cartes
                    child: snapshot.connectionState == ConnectionState.waiting
                        ? ListView.builder(
                            scrollDirection:
                                Axis.horizontal, // Défilement horizontal
                            itemCount: 3, // Nombre de cartes shimmer à afficher
                            itemBuilder: (context, index) {
                              return Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: 150, // Ajuste la largeur des cartes
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    color: Colors.white,
                                    elevation: 1.0,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            color: Colors.grey[
                                                300], // Couleur de fond pour l'effet shimmer
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Container(
                                            height:
                                                10, // Hauteur pour le texte shimmer
                                            color: Colors.grey[300],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : ListView.builder(
                            scrollDirection:
                                Axis.horizontal, // Défilement horizontal
                            itemCount: filteredPlantes.length,
                            itemBuilder: (context, index) {
                              final plante = filteredPlantes[index];

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
                                  margin: const EdgeInsets.symmetric(
                                      horizontal:
                                          10), // Espace entre les cartes
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          15), // Coins arrondis
                                    ),
                                    color: Colors.white,
                                    elevation: 1.0,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: Stack(
                                            children: [
                                              // Utilise le builder pour gérer le chargement d'image
                                              Image.network(
                                                plante['image']!,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                                loadingBuilder:
                                                    (BuildContext context,
                                                        Widget child,
                                                        ImageChunkEvent?
                                                            loadingProgress) {
                                                  if (loadingProgress == null) {
                                                    return child; // Affiche l'image quand elle est chargée
                                                  } else {
                                                    return Container(
                                                      color: Colors.grey[
                                                          300], // Affiche une couleur grise pendant le chargement
                                                    );
                                                  }
                                                },
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Container(
                                                    color: Colors.grey[
                                                        300], // Affiche une couleur grise en cas d'erreur
                                                  );
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
                },
              ),
              SizedBox(height: 10),
              //-----------CENTRE PAGE-----------------------------------------------------
              // Section Explorez nos plantes
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Explorez nos centres',
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
                future: _futureCentres,
                builder: (context, snapshot) {
                  return SizedBox(
                    height:
                        200, // Ajuste la hauteur pour s'adapter à la taille des cartes
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal, // Défilement horizontal
                      itemCount:
                          snapshot.connectionState == ConnectionState.waiting
                              ? 5
                              : centres.length, // Utilise 5 pour le shimmer
                      itemBuilder: (context, index) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // Afficher l'effet shimmer
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 160, // Ajuste la largeur des cartes
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      15), // Coins arrondis
                                ),
                                color: Colors.white,
                                elevation:
                                    2.0, // Élévation pour un effet d'ombre
                                shadowColor: Colors.grey.withOpacity(0.8),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                          top: Radius.circular(15),
                                        ),
                                        child: Container(
                                            color: Colors
                                                .white), // Conteneur blanc pour l'effet
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 16, // Hauteur du texte
                                            color: Colors
                                                .white, // Conteneur blanc pour l'effet
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            height: 14, // Hauteur du texte
                                            color: Colors
                                                .white, // Conteneur blanc pour l'effet
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else {
                          final centre = centres[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailsCentre(centre: centre),
                                ),
                              );
                            },
                            child: Container(
                              width: 160, // Ajuste la largeur des cartes
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10), // Espace entre les cartes
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      15), // Coins arrondis
                                ),
                                color: Colors.white,
                                elevation:
                                    2.0, // Élévation pour un effet d'ombre
                                shadowColor: Colors.grey
                                    .withOpacity(0.8), // Ombre plus subtile
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Image en haut avec un léger arrondi
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                          top: Radius.circular(15),
                                        ),
                                        child: Image.network(
                                          centre['image'],
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                          errorBuilder: (BuildContext context,
                                              Object exception,
                                              StackTrace? stackTrace) {
                                            return Icon(Icons.error,
                                                color: Colors.red);
                                          },
                                        ),
                                      ),
                                    ),
                                    // Informations du centre : nom et adresse avec icônes et alignement à gauche
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 10.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start, // Alignement à gauche
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.business,
                                                  size: 16,
                                                  color:
                                                      couleurPrincipale), // Icône pour le nom
                                              SizedBox(
                                                  width:
                                                      5), // Espacement entre l'icône et le texte
                                              Expanded(
                                                child: Text(
                                                  centre['nom'],
                                                  style: const TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontWeight: FontWeight.w600,
                                                    fontSize:
                                                        14, // Taille un peu plus grande pour le nom
                                                    color:
                                                        couleurPrincipale, // Couleur légèrement atténuée
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                              height:
                                                  4), // Espacement entre le nom et l'adresse
                                          Row(
                                            children: [
                                              Icon(Icons.location_on,
                                                  size: 16,
                                                  color:
                                                      couleurPrincipale), // Icône pour l'adresse
                                              SizedBox(
                                                  width:
                                                      5), // Espacement entre l'icône et le texte
                                              Expanded(
                                                child: Text(
                                                  centre['adresse'],
                                                  style: const TextStyle(
                                                    fontFamily: policeLato,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize:
                                                        12, // Taille plus petite pour l'adresse
                                                    color:
                                                        couleurPrincipale, // Couleur grise pour différencier visuellement
                                                  ),
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
                        }
                      },
                    ),
                  );
                },
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
