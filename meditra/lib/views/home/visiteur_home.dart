import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';
import 'package:meditra/sevices/consultation_service.dart';
import 'package:meditra/views/home/consultation_approuve.dart';
import 'package:meditra/views/home/visiteur_consultation_all.dart';
import 'package:meditra/views/home_praticien/DiscussionPage.dart';

class VisitorHomeScreen extends StatefulWidget {
  const VisitorHomeScreen({Key? key}) : super(key: key);

  @override
  State<VisitorHomeScreen> createState() => _VisitorHomeScreenState();
}

class _VisitorHomeScreenState extends State<VisitorHomeScreen> {
  final ConsultationService _consultationService = ConsultationService();
  Future<Map<String, dynamic>?>? _futureConsultation;

  @override
  void initState() {
    super.initState();
    // Appel pour récupérer la dernière consultation approuvée
    _futureConsultation =
        _consultationService.fetchDerniereConsultationAppVisiteur();
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
      backgroundColor: Colors.white,
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
                          builder: (context) =>
                              VisiteurConsultationAllScreen(),
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
              SizedBox(height: 5),

              // Section Explorez nos remèdes, etc...
            ],
          ),
        ),
      ),
    );
  }
}
