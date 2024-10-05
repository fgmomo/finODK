import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meditra/config/config.dart';
import 'package:meditra/sevices/consultation_service.dart';
import 'package:meditra/views/home_praticien/praticien_all_consultation.dart'; 

class PraticienConsultationScreen extends StatefulWidget {
  const PraticienConsultationScreen({super.key});

  @override
  State<PraticienConsultationScreen> createState() =>
      _PraticienConsultationScreenState();
}

class _PraticienConsultationScreenState
    extends State<PraticienConsultationScreen> {
  late Future<List<Map<String, dynamic>>> consultationsFuture;

  @override
  void initState() {
    super.initState();
    consultationsFuture =
        ConsultationService().fetchConsultations(); // Utilisation du service
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Consultation',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
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
            onPressed: () {
              // Logique de notification
            },
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: consultationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Erreur lors du chargement des consultations.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucune consultation en attente.'));
          } else {
            var consultations = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Consultation en attente
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Consultation en attente',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: policeLato),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PraticienAllConsultationScreen()), // Assurez-vous de créer cette page
                            );
                          },
                          child: Text(
                            'Voir tout',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: policeLato),
                          ),
                        ),
                      ],
                    ),

                    // Liste scrollable horizontalement de consultations en attente
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: consultations.map((consultation) {
                          String visiteur = consultation['visiteur'];
                          String profileImageUrl =
                              consultation['profileImageUrl'] ??
                                  ''; // URL de l'image de profil
                          String date = formatDate(
                              consultation['dateDemande'].toString());
                          String heureDebut =
                              consultation['crenau']['heure_debut'].toString();
                          String heureFin =
                              consultation['crenau']['heure_fin'].toString();
                          String message = consultation['message'];

                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 8.0),
                            width: 300, // Largeur de chaque carte
                            child: Card(
                              elevation: 2,
                              color: Color(0xFFF5F5F5),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Affichage de l'image de profil et du nom du patient
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundImage: profileImageUrl
                                                      .isNotEmpty
                                                  ? NetworkImage(
                                                      profileImageUrl)
                                                  : AssetImage(
                                                      'assets/prof.jpg'), // Image par défaut
                                              radius: 25,
                                            ),
                                            SizedBox(
                                                width:
                                                    10), // Espacement entre l'image et le texte
                                            Text(
                                              visiteur,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: policeLato),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.remove_red_eye,
                                              color: couleurPrincipale),
                                          onPressed: () {
                                            // Afficher le message dans un dialog
                                            showMessageDialog(message);
                                          },
                                        ),
                                      ],
                                    ),
                                    Divider(height: 10, color: Colors.black),
                                    SizedBox(height: 5),
                                    // Date et Heure
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
                                    // Boutons Approuver et Rejeter
                                    SizedBox(height: 15),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            // Logique pour approuver
                                          },
                                          child: Text('Approuver',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: policePoppins)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: couleurPrincipale,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 13, horizontal: 25),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            // Logique pour rejeter
                                          },
                                          child: Text('Rejeter',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: policePoppins)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFFC98181),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 13, horizontal: 25),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
