import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';

class DetailPlanteScreen extends StatefulWidget {
  final String nomPlante; // Nom de la plante
  final String imagePlante; // Image de la plante
  final String? nomLocal; // Nom local facultatif
  final String? description;
  final String? bienfaits;

  const DetailPlanteScreen({
    super.key,
    required this.nomPlante,
    required this.imagePlante,
    this.nomLocal, // Paramètre optionnel
    required this.description,
    required this.bienfaits,
  });

  @override
  _DetailPlanteScreenState createState() => _DetailPlanteScreenState();
}

class _DetailPlanteScreenState extends State<DetailPlanteScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Trois onglets
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text(
          'Détails de la Plante', // Titre de l'AppBar
          style: TextStyle(
            fontFamily: policeLato,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        // elevation: ,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0), // Bordure fine
          child: Container(
            color: Colors.black,
            height: 0.2,
          ),
        ),
      ),
      body: Column(
        children: [
          // Image centrée
          Container(
            margin: const EdgeInsets.all(20),
            width: 400,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                  15.0), // Ajoute le border radius à l'image
              child: Image.network(
                widget.imagePlante, // URL de l'image venant de Firestore
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons
                      .error); // Afficher une icône d'erreur si l'image ne se charge pas
                },
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child; // L'image est chargée
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    ); // Affiche un loader pendant le chargement
                  }
                },
              ),
            ),
          ),
          // Affichage du nom de la plante
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              widget.nomPlante, // Affiche le nom de la plante
              style: const TextStyle(
                fontFamily: policePoppins,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Affichage du nom local s'il existe
          if (widget.nomLocal != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                widget.nomLocal!, // Affiche le nom local
                style: const TextStyle(
                  fontFamily: policePoppins,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey, // Couleur pour le nom local
                ),
                textAlign: TextAlign.center,
              ),
            ),
    
          // TabBar
          TabBar(
            controller: _tabController,
            labelColor:
                Colors.black, // Couleur du texte de l'onglet sélectionné
            unselectedLabelColor:
                Colors.grey, // Couleur du texte des onglets non sélectionnés
            indicatorColor: couleurPrincipale, // Couleur de l'indicateur actif
            labelStyle: const TextStyle(
              fontFamily:
                  policePoppins, // Police pour le texte des onglets sélectionnés
              fontWeight:
                  FontWeight.bold, // Style de la police (par exemple, gras)
              fontSize: 14, // Taille de la police pour les onglets sélectionnés
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily:
                  policePoppins, // Police pour le texte des onglets non sélectionnés
              fontWeight: FontWeight
                  .normal, // Style de la police pour les onglets non sélectionnés
              fontSize:
                  14, // Taille de la police pour les onglets non sélectionnés
            ),
            tabs: const [
              Tab(text: 'Description'),
              Tab(text: 'Bienfaits'),
              // Tab(text: 'Utilisation'),
            ],
          ),
          // Contenu des onglets
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Onglet 1 : Description de la plante (statique)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Text(
                      widget.description!,
                      style: const TextStyle(
                        fontFamily: policePoppins,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                // Onglet 2 : Bienfaits
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Text(
                      widget.bienfaits!,
                      style: const TextStyle(
                        fontFamily: policePoppins,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
