import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';

class VisitorHomeScreen extends StatefulWidget {
    const VisitorHomeScreen({Key? key}) : super(key: key);
  @override
  State<VisitorHomeScreen> createState() => _VisitorHomeScreenState();
}

class _VisitorHomeScreenState extends State<VisitorHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        // elevation: 0.0, // Supprimer l'ombre de l'AppBar
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenue,',
              style: TextStyle(
                fontSize: 22,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: policeLato, // Utiliser la police définie
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
              color: couleurPrincipale, // Couleur de l'icône
              size: 35, // Taille de l'icône
            ),
            onPressed: () {
              // Logique de notification
            },
            padding:
                EdgeInsets.all(10), // Ajoute un peu d'espace autour de l'icône
            tooltip:
                'Notifications', // Ajoute un tooltip pour plus d'accessibilité
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0), // Bordure fine
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
              // Section Mes consultations à venir
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Mes consultations à venir',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: policeLato,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Logique pour voir tout
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

              // Carte de consultation
              SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [
                couleurPrincipale,
                const Color.fromARGB(255, 2, 39, 4)
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
                            child: Image.network(
                              'https://via.placeholder.com/50', // Remplace par l'URL de la photo du praticien
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dr Kontere', // Remplace par le nom du praticien
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontFamily: policeLato,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Statut : Approuvé', // Statut de la consultation
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Divider(
                          color: Colors.white, thickness: 1), // Ligne blanche
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today, color: Colors.white),
                              SizedBox(width: 5),
                              Text(
                                'Samedi, 3 Déc', // Date de la consultation
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: policePoppins,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.access_time, color: Colors.white),
                              SizedBox(width: 5),
                              Text(
                                '11:00 - 12:00', // Heure de la consultation
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
              ),

              SizedBox(height: 5), // Espacement entre les sections

              // Section Explorez nos remèdes
              Row(
                children: [
                  Text(
                    'Explorez nos remèdes',
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: policeLato,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () {
                      // Logique pour voir tout
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

              // Maladies scrollables horizontalement
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 10, // Nombre de maladies
                  itemBuilder: (context, index) {
                    return Container(
                      width: 100,
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  couleurSecondaire, // Couleur de fond de l'icône
                            ),
                            padding: EdgeInsets.all(15),
                            child: Icon(
                              Icons.grass, // Icône représentant la maladie
                              size: 35,
                              color: couleurPrincipale, // Couleur de l'icône
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Maladie $index', // Nom de la maladie
                            style: TextStyle(
                              color: Colors.black, // Couleur du texte
                              fontFamily: policePoppins,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 5),

              // Section Nos plantes
              Row(
                children: [
                  Text(
                    'Nos plantes',
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: policeLato,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () {
                      // Logique pour voir tout
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

              // Plantes scrollables horizontalement
              SizedBox(
                height:
                    200, // Ajustement de la hauteur pour une image plus grande
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildPlanteCard(
                      'Aloe Vera',
                      'https://via.placeholder.com/150', // Remplace par l'image de la plante
                    ),
                    _buildPlanteCard(
                      'Menthe',
                      'https://via.placeholder.com/150', // Remplace par l'image de la plante
                    ),
                    _buildPlanteCard(
                      'Basilic',
                      'https://via.placeholder.com/150', // Remplace par l'image de la plante
                    ),
                    _buildPlanteCard(
                      'Lavande',
                      'https://via.placeholder.com/150', // Remplace par l'image de la plante
                    ),
                  ],
                ),
              ),

              // Section Nos plantes
              Row(
                children: [
                  Text(
                    'Découvrez nos praticiens',
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: policeLato,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () {
                      // Logique pour voir tout
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

              // Plantes scrollables horizontalement
              SizedBox(
                height:
                    200, // Ajustement de la hauteur pour une image plus grande
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildPlanteCard(
                      'Aloe Vera',
                      'https://via.placeholder.com/150', // Remplace par l'image de la plante
                    ),
                    _buildPlanteCard(
                      'Menthe',
                      'https://via.placeholder.com/150', // Remplace par l'image de la plante
                    ),
                    _buildPlanteCard(
                      'Basilic',
                      'https://via.placeholder.com/150', // Remplace par l'image de la plante
                    ),
                    _buildPlanteCard(
                      'Lavande',
                      'https://via.placeholder.com/150', // Remplace par l'image de la plante
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

  // Fonction pour créer une carte de plante
  Widget _buildPlanteCard(String nom, String imageUrl) {
    return Container(
      width: 130, // Ajustement de la largeur pour une image plus grande
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Container(
            height: 150, // Ajustement de la hauteur de l'image
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), // Bordures arrondies
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            nom,
            style: TextStyle(
              fontFamily: policeLato,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
