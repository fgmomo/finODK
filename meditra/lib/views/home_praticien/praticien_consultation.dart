import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';
import 'package:meditra/views/home_praticien/praticien_all_consultation.dart';
import 'package:meditra/views/home_praticien/praticien_all_consultation_historique%20.dart';
import 'package:meditra/views/home_praticien/praticien_crenaux.dart';


class PraticienConsultationScreen extends StatefulWidget {
  const PraticienConsultationScreen({super.key});

  @override
  State<PraticienConsultationScreen> createState() =>
      _PraticienConsultationScreenState();
}

class _PraticienConsultationScreenState
    extends State<PraticienConsultationScreen> {
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Button Mes créneaux avec une icône œil
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                PraticienCrenauxScreen()), // Assure-toi de créer cette page
                      );
                    },
                    icon: Icon(Icons.remove_red_eye, color: Colors.white),
                    label: Text(
                      'Mes créneaux',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: couleurPrincipale,
                      padding:
                          EdgeInsets.symmetric(vertical: 13, horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),

              // Séparateur
              Divider(
                  height: 0.1, color: const Color.fromARGB(255, 187, 187, 187)),
              SizedBox(height: 10),

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
                                PraticienAllConsultationScreen()), // Assure-toi de créer cette page
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
                  children: List.generate(5, (index) {
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
                              // Nom du patient et icône œil
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Patient ${index + 1}',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: policeLato),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.remove_red_eye,
                                        color: couleurPrincipale),
                                    onPressed: () {
                                      // Logique pour voir les détails de la consultation
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
                                      Text('01/01/2024',
                                          style: TextStyle(
                                              fontFamily: policeLato)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time,
                                          color: couleurPrincipale),
                                      SizedBox(width: 5),
                                      Text('14:00 - 15:00',
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
                                        borderRadius: BorderRadius.circular(8),
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
                                        borderRadius: BorderRadius.circular(8),
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
                  }),
                ),
              ),
              SizedBox(height: 20),

              // Section Historique des consultations
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Historique des consultations',
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
                                PraticienAllConsultationHistoriqueScreen()), // Assure-toi de créer cette page
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

              // Section avec des cartes scrollables horizontalement
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(5, (index) {
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
                              // Nom du patient et icône œil
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Patient ${index + 1}',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: policeLato),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.remove_red_eye,
                                        color: Colors.black),
                                    onPressed: () {
                                      // Logique pour voir la discussion
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
                                      Text('01/01/2024',
                                          style: TextStyle(
                                              fontFamily: policeLato)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time,
                                          color: couleurPrincipale),
                                      SizedBox(width: 5),
                                      Text('14:00 - 15:00',
                                          style: TextStyle(
                                              fontFamily: policeLato)),
                                    ],
                                  ),
                                ],
                              ),
                              // Bouton Voir la discussion
                              SizedBox(height: 15),
                              ElevatedButton(
                                onPressed: () {
                                  // Logique pour voir la discussion
                                },
                                child: Text('Voir la discussion',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: policePoppins)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 13, horizontal: 25),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
