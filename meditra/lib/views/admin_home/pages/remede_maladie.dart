import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';
import 'package:meditra/sevices/remede_maladie_service.dart';
import 'package:meditra/views/admin_home/pages/assoc_reme_maladie__modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RemedeMaladiePage extends StatefulWidget {
  const RemedeMaladiePage({super.key});

  @override
  State<RemedeMaladiePage> createState() => _RemedeMaladiePageState();
}

class _RemedeMaladiePageState extends State<RemedeMaladiePage> {
  final RemedeMaladieService _remedeMaladieService = RemedeMaladieService();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
     appBar: AppBar(
      scrolledUnderElevation: 0,
      // elevation: 0,
        backgroundColor: Colors.grey[200],
        title: Row(
          children: [
            Text('Liste des Rémèdes par maladie',
                style: TextStyle(fontFamily: policePoppins)),
            SizedBox(width: 10),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return RemedeMaladieModal();
                  },
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: couleurPrincipale,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              child: Text(
                'Associer un rémède à une maladie',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: policePoppins,
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: 200,
              child: TextField(
                onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                },
                decoration: InputDecoration(
                  hintText: "Rechercher...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                ),
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _remedeMaladieService.getRemedesAndMaladies(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Aucun remède trouvé.'));
            }

            // Filtrage des résultats de recherche
            final remedesMaladies = snapshot.data!
                .where((remedeMaladie) =>
                    remedeMaladie['remede']['nom']
                        .toLowerCase()
                        .contains(searchQuery) ||
                    remedeMaladie['maladie']['nom']
                        .toLowerCase()
                        .contains(searchQuery))
                .toList();

            if (remedesMaladies.isEmpty) {
              return Center(child: Text('Aucun résultat pour "$searchQuery"'));
            }

          return Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.1),
        spreadRadius: 2,
        blurRadius: 5,
        offset: const Offset(0, 3),
      ),
    ],
  ),
  child: SingleChildScrollView( // Ajoutez ceci
    scrollDirection: Axis.vertical, // Défilement vertical
    child: Table(
      columnWidths: const {
        0: FlexColumnWidth(2), // Nom du remède
        1: FlexColumnWidth(2), // Maladie associée
        2: FlexColumnWidth(3), // Description
        3: FlexColumnWidth(2), // Utilisation
        4: FlexColumnWidth(3), // Image
        5: FlexColumnWidth(1), // Actions
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          children: [
            _buildTableHeader('Nom Remède'),
            _buildTableHeader('Maladie Associée'),
            _buildTableHeader('Description Résumée'),
            _buildTableHeader('Utilisation'),
            _buildTableHeader('Image'),
            _buildTableHeader('Actions'),
          ],
        ),
        ...remedesMaladies.map((remedeMaladie) {
          final remede = remedeMaladie['remede'];
          final maladie = remedeMaladie['maladie'];

          return TableRow(
            decoration: BoxDecoration(
              color: remedesMaladies.indexOf(remedeMaladie).isEven
                  ? Colors.white
                  : Colors.grey[100],
            ),
            children: [
              _buildTableCell(remede['nom']),
              _buildTableCell(maladie['nom']),
              _buildTableCell(_getShortDescription(remede['description'])),
              _buildTableCell(remede['utilisation']),
              _buildImageCell(remede['image']),
              _buildActionIcons(remedeMaladie),
            ],
          );
        }).toList(),
      ],
    ),
  ),
);
          },
        ),
      ),
    );
  }

  String _getShortDescription(String description) {
    return description.length > 50
        ? '${description.substring(0, 50)}...'
        : description;
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          fontFamily: 'Poppins',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'Poppins',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildImageCell(String imageUrl) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: CircleAvatar(
        radius: 25,
        backgroundImage: imageUrl != null && imageUrl.isNotEmpty
            ? NetworkImage(
                imageUrl,
              ) // Affiche l'image de profil à partir de l'URL
            : AssetImage('assets/prof.jpg'), // Image par défaut
      ),
    );
  }
  Widget _buildActionIcons(Map<String, dynamic> remedeMaladie) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: IconButton(
              icon: const Icon(Icons.remove_red_eye, color: Colors.green),
              onPressed: () {
                _showRemedeDetails(remedeMaladie['remede']);
              },
            ),
          ),
         Flexible(
  child: IconButton(
    icon: const Icon(Icons.link_off, color: Colors.red),
    onPressed: () async {
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmation'),
            content: const Text('Êtes-vous sûr de vouloir dissocier ce remède de cette maladie ?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Annuler'),
                onPressed: () {
                  Navigator.of(context).pop(false); // Ne pas dissocier
                },
              ),
              TextButton(
                child: const Text('Confirmer'),
                onPressed: () {
                  Navigator.of(context).pop(true); // Confirmer la dissociation
                },
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        await _dissocierRemedeMaladie(remedeMaladie);
      }
    },
  ),
),
        ],
      ),
    );
  }



  Future<void> _showRemedeDetails(Map<String, dynamic> remede) async {
    showDialog(
      context: context,
      builder: (context) {
       
  return AlertDialog(
          title:
              Text(remede['nom'], style: TextStyle(fontFamily: policePoppins)),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 300,
              maxHeight: 400,
              minWidth: 300,
              maxWidth: 500,
            ),
            child: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      remede['image'],
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.broken_image, size: 150);
                      },
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nom du rémède', // Titre en gras
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: policePoppins,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          remede['nom'], // Contenu en dessous
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontFamily: policePoppins,
                          ),
                        ),
                        SizedBox(height: 10),

                        // Description
                        Text(
                          'Description', // Titre en gras
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: policePoppins,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          remede['description'], // Contenu en dessous
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontFamily: policePoppins,
                          ),
                        ),
                        SizedBox(height: 10),

                        // Utilisation
                        Text(
                          'Utilisation', // Titre en gras
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: policePoppins,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          remede['utilisation'], // Contenu en dessous
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontFamily: policePoppins,
                          ),
                        ),
                        SizedBox(height: 10),

                        // Précaution
                        Text(
                          'Précaution', // Titre en gras
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: policePoppins,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          remede['precaution'], // Contenu en dessous
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontFamily: policePoppins,
                          ),
                        ),
                        SizedBox(height: 10),

                        // Dosage
                        Text(
                          'Dosage', // Titre en gras
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: policePoppins,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          remede['dosage'], // Contenu en dessous
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontFamily: policePoppins,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fermer',
                  style: TextStyle(
                      color: Colors.green[700], fontFamily: policePoppins)),
            ),
          ],
        );

      },
    );
  }

   Future<void> _dissocierRemedeMaladie(
      Map<String, dynamic> remedeMaladie) async {
    print('Tentative de dissociation...');

    // Récupérer les références des remèdes et maladies
    final remedeRef = remedeMaladie['remede_ref'] as DocumentReference?;
    final maladieRef = remedeMaladie['maladie_ref'] as DocumentReference?;

    // Vérifiez si les références sont nulles
    if (remedeRef == null) {
      print('Erreur: Référence de remède est null.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur: Référence de remède invalide.')),
      );
      return;
    }

    if (maladieRef == null) {
      print('Erreur: Référence de maladie est null.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur: Référence de maladie invalide.')),
      );
      return;
    }

    print('Remede Ref: $remedeRef, Maladie Ref: $maladieRef');

    // Appel de la méthode pour dissocier
    await _remedeMaladieService.dissocierRemedeMaladie(remedeMaladie);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Le remède a été dissocié de la maladie.')),
    );
  }
}
