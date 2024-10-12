import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meditra/config/config.dart';
import 'package:meditra/sevices/consultation_service.dart';
import 'package:meditra/views/home_praticien/DiscussionPage.dart';

class VisiteurAllApprouveConsultationScreen extends StatefulWidget {
  const VisiteurAllApprouveConsultationScreen({super.key});

  @override
  State<VisiteurAllApprouveConsultationScreen> createState() =>
      _VisiteurAllApprouveConsultationScreenState();
}

class _VisiteurAllApprouveConsultationScreenState
    extends State<VisiteurAllApprouveConsultationScreen> {
  late Future<List<Map<String, dynamic>>> consultationsFuture;
  List<Map<String, dynamic>> allConsultations = [];
  List<Map<String, dynamic>> filteredConsultations = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    consultationsFuture =
        fetchAndSetConsultations(); // Récupération initiale des consultations
  }

  Future<List<Map<String, dynamic>>> fetchAndSetConsultations() async {
    allConsultations = await ConsultationService().fetchConsultationsApp();
    setState(() {
      filteredConsultations =
          allConsultations; // Initialement, toutes les consultations sont affichées
    });
    return allConsultations;
  }

  String formatDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void showMessageDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Coins arrondis
          ),
          title: Text('Message du Patient',
              style: TextStyle(
                  fontFamily: policeLato, fontWeight: FontWeight.bold)),
          content: Text(message, style: TextStyle(fontFamily: policePoppins)),
          actions: <Widget>[
            TextButton(
              child: Text('Fermer',
                  style: TextStyle(
                      fontFamily: policeLato,
                      fontWeight: FontWeight.bold,
                      color: couleurPrincipale,
                      fontSize: 18)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void filterConsultations(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredConsultations = allConsultations
          .where((consultation) => consultation['visiteur']
              .toString()
              .toLowerCase()
              .contains(searchQuery))
          .toList(); // Filtre les consultations en fonction de la requête
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: consultationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Erreur lors du chargement des consultations.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucune consultation approuvé.'));
          } else {
            var consultations =
                filteredConsultations; // Utilisation des consultations filtrées
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 10), // Aligné avec la barre de recherche
                  ),
                  // Barre de recherche
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Rechercher une consultation...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onChanged: (query) {
                        filterConsultations(
                            query); // Appelle la méthode de filtrage
                      },
                    ),
                  ),
                  // Titre de la section en petite taille
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Historiques de consultation',
                      style: TextStyle(
                        fontSize: 16, // Taille réduite
                        fontWeight: FontWeight.bold,
                        fontFamily: policeLato,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // Liste des consultations
                  ListView.builder(
                    itemCount: consultations.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      var consultation = consultations[index];

                      String reference = consultation['reference'];
                      String visiteur = consultation['visiteur'];
                      String profileImageUrl =
                          consultation['profileImageUrl'] ?? '';
                      String date =
                          formatDate(consultation['dateDemande'].toString());
                      String heureDebut =
                          consultation['crenau']['heure_debut'].toString();
                      String heureFin =
                          consultation['crenau']['heure_fin'].toString();
                      String message = consultation['message'];

                      return Container(
                        margin: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Card(
                          elevation: 2,
                          color: Color(0xFFF5F5F5),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: profileImageUrl
                                                  .isNotEmpty
                                              ? NetworkImage(profileImageUrl)
                                              : AssetImage('assets/prof.jpg'),
                                          radius: 25,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          visiteur,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: policeLato,
                                          ),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.remove_red_eye,
                                        color: couleurPrincipale,
                                      ),
                                      onPressed: () {
                                        showMessageDialog(message);
                                      },
                                    ),
                                  ],
                                ),
                                Divider(height: 10, color: Colors.black),
                                SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today,
                                            color: couleurPrincipale),
                                        SizedBox(width: 5),
                                        Text(date,
                                            style: TextStyle(
                                                fontFamily: policeLato)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.access_time,
                                            color: couleurPrincipale),
                                        SizedBox(width: 5),
                                        Text('$heureDebut - $heureFin',
                                            style: TextStyle(
                                                fontFamily: policeLato)),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 15),
                                // Bouton Ouvrir la discussion

                                Align(
                                  alignment:
                                      Alignment.centerLeft, // Aligné à gauche
                                  child: ElevatedButton(
                                    onPressed: () {   
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
                                    child: Text(
                                      'Ouvrir la Discussion',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: policePoppins,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 13, horizontal: 25),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
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
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
