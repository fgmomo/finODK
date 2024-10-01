import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';

class PraticienAllConsultationHistoriqueScreen extends StatefulWidget {
  const PraticienAllConsultationHistoriqueScreen({super.key});

  @override
  State<PraticienAllConsultationHistoriqueScreen> createState() =>
      _PraticienAllConsultationHistoriqueScreenState();
}

class _PraticienAllConsultationHistoriqueScreenState
    extends State<PraticienAllConsultationHistoriqueScreen> {
  List<String> patients = List.generate(
      10, (index) => 'Nom du Patient ${index + 1}'); // Liste des patients
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Filtrer les patients en fonction de la recherche
    final filteredPatients = patients
        .where((patient) =>
            patient.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Historiques de Consultations',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: policeLato,
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
              SizedBox(height: 15),

              // Barre de recherche
              TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery =
                        value; // Mettre à jour la requête de recherche
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Rechercher un patient...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  prefixIcon: Icon(Icons.search),
                ),
              ),

              SizedBox(height: 15), // Espace entre la barre de recherche et la liste

              // Liste des consultations
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: filteredPatients.length, // Utiliser la liste filtrée
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2,
                    color: Color(0xFFF5F5F5), // Couleur de la carte
                    margin: EdgeInsets.symmetric(
                        vertical: 8), // Espace entre les éléments
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nom du patient et icône œil
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                filteredPatients[index],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: policeLato,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.remove_red_eye,
                                    color: couleurPrincipale),
                                onPressed: () {
                                  // Logique pour afficher le message
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      title: Text(
                                        'Message du Patient',
                                        style: TextStyle(
                                          fontFamily: policePoppins,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      content: Text(
                                        'Message du patient concernant la consultation...',
                                        style: TextStyle(
                                            fontFamily: policePoppins),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: Text(
                                            'Fermer',
                                            style: TextStyle(
                                              color: couleurPrincipale,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          Divider(height: 10, color: Colors.black),
                          SizedBox(height: 5),

                          // Date et Heure
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      color: couleurPrincipale),
                                  SizedBox(width: 5),
                                  Text('01/01/2024',
                                      style: TextStyle(fontFamily: policeLato)),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.access_time,
                                      color: couleurPrincipale),
                                  SizedBox(width: 5),
                                  Text('14:00 - 15:00',
                                      style: TextStyle(fontFamily: policeLato)),
                                ],
                              ),
                            ],
                          ),

                          // Bouton Ouvrir la discussion
                          SizedBox(height: 15),
                          Align(
                            alignment: Alignment.centerLeft, // Aligné à gauche
                            child: ElevatedButton(
                              onPressed: () {
                                // Logique pour ouvrir la discussion
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
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
