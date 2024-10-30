import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shimmer/shimmer.dart'; // Importez le package Shimmer
import 'package:meditra/config/config.dart';

class RemedeListScreen extends StatefulWidget {
  final String nomMaladie;
  final String descriptionMaladie;

  RemedeListScreen({
    required this.nomMaladie,
    required this.descriptionMaladie,
  });

  @override
  _RemedeListScreenState createState() => _RemedeListScreenState();
}

class _RemedeListScreenState extends State<RemedeListScreen> {
  List<Map<String, dynamic>> remedes = [];
  String searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRemedes();
  }

  Future<void> _fetchRemedes() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('maladies')
          .where('nom', isEqualTo: widget.nomMaladie)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('Aucune maladie trouvée avec le nom: ${widget.nomMaladie}');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      DocumentReference maladieRef = querySnapshot.docs.first.reference;
      print('Référence de la maladie: ${maladieRef.path}');

      QuerySnapshot remedeQuerySnapshot = await FirebaseFirestore.instance
          .collection('remede_maladie')
          .where('maladie_ref', isEqualTo: maladieRef)
          .get();

      if (remedeQuerySnapshot.docs.isEmpty) {
        print('Aucun remède trouvé pour cette maladie');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      List<String> remedeRefs = remedeQuerySnapshot.docs.map((doc) {
        return (doc['remede_ref'] as DocumentReference).id.trim();
      }).toList();
      print('Références des remèdes: $remedeRefs');

      List<Map<String, dynamic>> fetchedRemedes = [];
      for (String remedeRef in remedeRefs) {
        DocumentSnapshot remedeDoc = await FirebaseFirestore.instance
            .collection('remedes')
            .doc(remedeRef)
            .get();

        if (remedeDoc.exists) {
          fetchedRemedes.add({
            'nom': remedeDoc['nom'],
            'description': remedeDoc['description'],
            'utilisation': remedeDoc['utilisation'],
            'dosage': remedeDoc['dosage'],
            'precaution': remedeDoc['precaution'],
            'image': remedeDoc['image'] ?? '',
          });
        } else {
          print('Le remède avec référence $remedeRef est introuvable dans la collection remedes.');
        }
      }

      setState(() {
        remedes = fetchedRemedes;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors de la récupération des remèdes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredRemedes = remedes.where((remede) {
      return remede['nom']!.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(
          'Remèdes pour ${widget.nomMaladie}',
          style: const TextStyle(
            fontFamily: policeLato,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        // elevation: 1,
      ),
      body: _isLoading
          ? Center(
              child: LoadingAnimationWidget.horizontalRotatingDots(
                color: couleurPrincipale,
                size: 200,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Rechercher un remède',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: Icon(Icons.search, color: couleurPrincipale),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: couleurPrincipale),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  filteredRemedes.isEmpty
                      ? Center(
                          child: Text(
                            "Aucun remède trouvé.",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredRemedes.length,
                          itemBuilder: (context, index) {
                            final remede = filteredRemedes[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 3,
                              child: ExpansionTile(
                                title: Text(
                                  remede['nom']!,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                children: [
                                  if (remede['image'] != '')
                                    Stack(
                                      children: [
                                        // Afficher le Shimmer pendant le chargement de l'image
                                        Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(
                                            height: 200, // Hauteur fixe pour l'image
                                            width: double.infinity,
                                            color: Colors.white, // Couleur de fond
                                          ),
                                        ),
                                        // Image qui s'affiche lorsque chargée
                                        Image.network(
                                          remede['image'],
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                                    : null,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Description',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: policeLato,
                                              fontSize: 18),
                                        ),
                                        Text(remede['description']!,
                                            style: TextStyle(
                                              fontFamily: policePoppins,
                                              fontSize: 15,
                                            )),
                                        const SizedBox(height: 15),
                                        Text(
                                          'Utilisation',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: policeLato,
                                              fontSize: 18),
                                        ),
                                        Text(remede['utilisation']!,
                                            style: TextStyle(
                                              fontFamily: policePoppins,
                                              fontSize: 15,
                                            )),
                                        const SizedBox(height: 15),
                                        Text(
                                          'Dosage',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: policeLato,
                                              fontSize: 18),
                                        ),
                                        Text(remede['dosage']!,
                                            style: TextStyle(
                                              fontFamily: policePoppins,
                                              fontSize: 15,
                                            )),
                                        const SizedBox(height: 15),
                                        Text(
                                          'Précautions',
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: policeLato,
                                              fontSize: 18),
                                        ),
                                        Text(remede['precaution']!,
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontFamily: policePoppins,
                                              fontSize: 15,
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}
