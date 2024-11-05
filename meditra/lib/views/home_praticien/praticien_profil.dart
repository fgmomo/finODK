import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditra/config/config.dart';
import 'package:meditra/views/auth/login_screen.dart';
import 'package:meditra/views/home/notification.dart';
import 'package:meditra/views/home/politique.dart';
import 'package:meditra/views/home/visiteur_edit_profil.dart';
import 'package:meditra/views/home_praticien/praticien_edit_profil.dart';
import 'package:shimmer/shimmer.dart'; // Ajoute cette ligne pour utiliser Shimmer

class PraticienProfilScreen extends StatefulWidget {
  const PraticienProfilScreen({super.key});

  @override
  State<PraticienProfilScreen> createState() => _PraticienProfilScreenState();
}

class _PraticienProfilScreenState extends State<PraticienProfilScreen> {
  String firstname = '';
  String lastname = '';
  String email = '';
  String role = '';
  String profileImageUrl =
      ''; // Ajoutez un champ pour l'URL de l'image de profil

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Mon profil',
          style: TextStyle(
            color: Colors.black,
            fontFamily: policeLato,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('praticiens')
            .doc(user?.uid)
            .snapshots(), // Écoutez les mises à jour du document
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Applique l'effet Shimmer ici pendant le chargement
            return _buildShimmerEffect();
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Profil introuvable'));
          }

          var visitorData = snapshot.data!.data() as Map<String, dynamic>;
          firstname = visitorData['firstName'] ?? 'Prénom inconnu';
          lastname = visitorData['lastName'] ?? 'Nom inconnu';
          email = user?.email ?? 'Email inconnu';
          role = visitorData['role'] ?? 'Role inconnu';
          profileImageUrl =
              visitorData['photoUrl'] ?? ''; // URL de l'image de profil

          return Column(
            children: [
              // Section du haut avec la photo et le nom de l'utilisateur
              Container(
                 decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: [
                couleurPrincipale,
                const Color.fromARGB(255, 2, 39, 4)
              ], 
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                width: double
                    .infinity, // Assure que la section couvre toute la largeur
                
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Image circulaire (photo de profil)
                    GestureDetector(
                      onTap: _pickImage, // Méthode pour choisir une image
                      child: profileImageUrl.isEmpty
                          ? Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors
                                    .white, // Couleur de fond pour l'avatar
                              ),
                            )
                          : CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(
                                  profileImageUrl), // Charge l'image réelle
                              backgroundColor: Colors.white,
                            ),
                    ),
                    const SizedBox(height: 20),
                    // Nom de l'utilisateur
                    Text(
                      '$firstname $lastname', // Affiche le nom et prénom récupérés
                      style: const TextStyle(
                        fontSize: 22,
                        fontFamily: policePoppins,
                        color: Colors.white,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                     Text(
                      '($role)', // Affiche le nom et prénom récupérés
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: policeLato,
                    
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Section des paramètres de profil
              Expanded(
                child: ListView(
                  children: [
                    _buildListItem(
                      icon: Icons.person,
                      title: 'Mon profil',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const PraticienEditProfilScreen()),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildListItem(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NotificationsScreen()),
                        );
                      },
                    ),
                    _buildDivider(),
                    // _buildListItem(
                    //   icon: Icons.help_outline,
                    //   title: 'Aide',
                    //   onTap: () {},
                    // ),
                    _buildDivider(),
                    _buildListItem(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Politique et confidentialité',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PrivacyPolicyScreen()),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildListItem(
                      icon: Icons.exit_to_app,
                      title: 'Déconnexion',
                      onTap: () async {
                        bool? confirm = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16), // Coins arrondis
                              ),
                              title: Text(
                                'Confirmer la déconnexion',
                                style: TextStyle(
                                  fontFamily: policeLato,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              content: Text(
                                'Êtes-vous sûr de vouloir vous déconnecter ?',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 15,
                                  color: Colors.grey[700],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              actions: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // Bouton Annuler
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(
                                            false); // Fermer la boîte de dialogue
                                      },
                                      child: Text(
                                        'Annuler',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    // Bouton Déconnexion
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop(
                                            true); // Confirmer la déconnexion
                                        await FirebaseAuth.instance.signOut();
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  LoginScreen()),
                                        ); // Rediriger
                                      },
                                      child: Text(
                                        'Déconnexion',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.red,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm == true) {
                          try {
                            await FirebaseAuth.instance
                                .signOut(); // Déconnexion de l'utilisateur
                            // Naviguer vers l'écran de connexion ou un autre écran
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Erreur de déconnexion : $e')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget pour l'effet shimmer pendant le chargement des données
  Widget _buildShimmerEffect() {
    return Column(
      children: [
        // Effet shimmer pour la section photo et nom
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: double.infinity,
            color: couleurPrincipale,
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 20),
                Container(
                  width: 100,
                  height: 20,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[400],
                  ),
                  title: Container(
                    height: 20,
                    color: Colors.grey[400],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    // Ajoute ici ta logique pour sélectionner une image
  }

  // Construire un élément de la liste avec une icône et un titre
  Widget _buildListItem(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: couleurPrincipale),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: policePoppins,
          fontSize: 15,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey[300],
      height: 1,
      thickness: 1,
    );
  }
}
