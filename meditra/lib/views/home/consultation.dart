import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';
import 'package:meditra/sevices/consultation_service.dart';

class VisiteurConsultationScreen extends StatefulWidget {
  const VisiteurConsultationScreen({super.key});

  @override
  State<VisiteurConsultationScreen> createState() =>
      _VisiteurConsultationScreenState();
}

class _VisiteurConsultationScreenState
    extends State<VisiteurConsultationScreen> {
  String searchQuery = '';
  String? visiteurId; // Variable pour stocker l'ID du visiteur

  @override
  void initState() {
    super.initState();
    _getVisiteurId(); // Récupérer l'ID du visiteur lors de l'initialisation
  }

// Fonction pour récupérer l'ID du visiteur
  Future<void> _getVisiteurId() async {
    // Assumons que tu récupères le visiteur authentifié avec Firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Récupère l'ID du document du visiteur depuis Firestore
      final doc = await FirebaseFirestore.instance
          .collection('visiteurs')
          .doc(user
              .uid) // Utilise l'UID de l'utilisateur pour récupérer son document
          .get();

      if (doc.exists) {
        setState(() {
          visiteurId =
              doc.id; // Assigner l'ID du document à la variable visiteurId
        });
      }
    }
  }

  // Fonction pour récupérer les créneaux disponibles
  Stream<List<Map<String, dynamic>>> getCrenauxDisponibles() {
    return FirebaseFirestore.instance
        .collection('crenaux')
        .where('status', isEqualTo: 'disponible')
        .snapshots()
        .asyncMap((snapshot) async {
      List<Future<Map<String, dynamic>>> futuresList =
          snapshot.docs.map((doc) async {
        final data = doc.data();
        final praticienDoc = await FirebaseFirestore.instance
            .collection('praticiens')
            .doc(data['praticien_id'])
            .get();

        final praticienData = praticienDoc.data();

        return {
          'id': doc.id, // Ajoutez l'ID ici
          'date': data['date'],
          'heure_debut': data['heure_debut'],
          'heure_fin': data['heure_fin'],
          'praticien':
              '${praticienData?['firstName']} ${praticienData?['lastName']}',
          'photoUrl': praticienData?['photoUrl'],
        };
      }).toList();

      return Future.wait(futuresList);
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _messageController = TextEditingController();

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
              // Barre de recherche
              TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Rechercher un praticien...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 15),

              // Section Les praticiens disponibles
              Text(
                'Les praticiens disponibles',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: policeLato,
                ),
              ),
              // SizedBox(height: 5),

              // StreamBuilder pour afficher les créneaux disponibles
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: getCrenauxDisponibles(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text('Erreur : ${snapshot.error}');
                  }

                  final crenaux = snapshot.data ?? [];

                  if (crenaux.isEmpty) {
                    return Text('Aucun créneau disponible.');
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: crenaux.length,
                    itemBuilder: (context, index) {
                      final crenau = crenaux[index];
                      final nomPraticien = crenau['praticien'];
                      final date = crenau['date'];
                      final heureDebut = crenau['heure_debut'];
                      final heureFin = crenau['heure_fin'];
                      final photoUrl = crenau['photoUrl']; // URL de la photo

                      // Filtrer la liste selon la barre de recherche
                      if (searchQuery.isNotEmpty &&
                          !nomPraticien
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase())) {
                        return Container(); // Ne rien afficher si la recherche ne correspond pas
                      }

                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: Card(
                          elevation: 2,
                          color: Color(0xFFF5F5F5),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Nom et Avatar du praticien
                                Row(
                                  children: [
                                    // Avatar circulaire
                                    CircleAvatar(
                                      radius: 20, // Ajuste la taille ici
                                      backgroundImage: photoUrl != null &&
                                              photoUrl.isNotEmpty
                                          ? NetworkImage(photoUrl)
                                          : AssetImage(
                                              'assets/prof.jpg'), // Remplace par ton image par défaut
                                    ),
                                    SizedBox(
                                        width:
                                            10), // Espacement entre l'avatar et le nom
                                    // Nom du praticien
                                    Text(
                                      nomPraticien,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: policeLato,
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(height: 15, color: Colors.black),
                                SizedBox(height: 10),
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
                                // Bouton Prendre rendez-vous
                                SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          title: Text(
                                            'Prendre Rendez-vous',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Veuillez laisser un message pour le praticien :',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              SizedBox(height: 10),
                                              TextField(
                                                controller: _messageController,
                                                maxLines: 3,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    borderSide: BorderSide(
                                                        color: Colors.grey),
                                                  ),
                                                  hintText: 'Votre message...',
                                                ),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Fermer le modal
                                              },
                                              child: Text(
                                                'Annuler',
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                if (visiteurId != null) {
                                                  // Utiliser l'ID du visiteur pour créer une consultation
                                                  String message =
                                                      _messageController
                                                          .text; // Récupère le message du TextField
                                                  String crenauId = crenau[
                                                      'id']; // Récupère l'ID du créneau ici.

                                                  final consultationService =
                                                      ConsultationService();

                                                  // Vérifie si le visiteur a déjà un RDV pour ce créneau
                                                  bool hasExistingAppointment =
                                                      await consultationService
                                                          .hasExistingConsultation(
                                                              crenauId,
                                                              visiteurId!);
                                                  // Réinitialiser le champ de texte après l'envoi réussi
                                                  _messageController.clear();
                                                    Navigator.of(context)
                                                          .pop();
                                                  if (hasExistingAppointment) {
                                                    // Si le visiteur a déjà un RDV, afficher un message d'erreur
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          backgroundColor:
                                                              Colors.white,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16),
                                                          ),
                                                          content: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            16),
                                                                child: Icon(
                                                                  Icons.error,
                                                                  size: 40,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: 20),
                                                              Text(
                                                                'Erreur : Rendez-vous déjà pris',
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      policePoppins,
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                              SizedBox(
                                                                  height: 10),
                                                              Text(
                                                                'Vous avez déjà pris un rendez-vous pour ce créneau. Veuillez en choisir un autre.',
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      policePoppins,
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                          .grey[
                                                                      700],
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                              SizedBox(
                                                                  height: 20),
                                                            ],
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(); // Fermer le message d'erreur
                                                              },
                                                              child: Text(
                                                                'Fermer',
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      policePoppins,
                                                                  color: Colors
                                                                      .red,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  } else {
                                                    // Si le visiteur n'a pas de RDV pour ce créneau, créer la consultation
                                                    try {
                                                      await consultationService
                                                          .createConsultation(
                                                              crenauId,
                                                              message,
                                                              visiteurId!);
                                                      // Réinitialiser le champ de texte après l'envoi réussi
                                                      _messageController
                                                          .clear();
                                                      Navigator.of(context)
                                                          .pop(); // Fermer le modal après l'envoi

                                                      // Afficher le message de confirmation
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            backgroundColor:
                                                                Colors.white,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16),
                                                            ),
                                                            content: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: Colors
                                                                        .green,
                                                                  ),
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              16),
                                                                  child: Icon(
                                                                    Icons.check,
                                                                    size: 40,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    height: 20),
                                                                Text(
                                                                  'Demande envoyée avec succès',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        policePoppins,
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color:
                                                                        couleurPrincipale,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                                SizedBox(
                                                                    height: 10),
                                                                Text(
                                                                  'Votre demande de consultation a bien été envoyée. Un praticien vous contactera bientôt.',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        policePoppins,
                                                                    fontSize:
                                                                        15,
                                                                    color: Colors
                                                                            .grey[
                                                                        700],
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                                SizedBox(
                                                                    height: 20),
                                                              ],
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(); // Fermer le message de confirmation
                                                                },
                                                                child: Text(
                                                                  'Fermer',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        policePoppins,
                                                                    color:
                                                                        couleurPrincipale,
                                                                    fontSize:
                                                                        16,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    } catch (e) {
                                                      // Gérer l'erreur
                                                      print(e);
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                            content: Text(
                                                                'Erreur lors de l\'envoi de la demande.')),
                                                      );
                                                    }
                                                  }
                                                }
                                              },
                                              child: Text(
                                                'Envoyer',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    couleurPrincipale,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 20),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Text(
                                    'Prendre rendez-vous',
                                    style: TextStyle(
                                      color: couleurPrincipale,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: policeLato,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: couleurSecondaire,
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
                    },
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
