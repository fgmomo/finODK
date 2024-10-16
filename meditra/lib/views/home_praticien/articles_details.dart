import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';
import 'package:meditra/sevices/articles_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Map<String, dynamic> article;

  ArticleDetailScreen({Key? key, required this.article}) : super(key: key);

  @override
  _ArticleDetailScreenState createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final ArticleService _articleService = ArticleService();
  final TextEditingController _avisController = TextEditingController();
  List<Map<String, dynamic>> _avisList = [];
  bool _showAvis = false; // Variable pour contrôler l'affichage des avis

  @override
  void initState() {
    super.initState();
    _fetchAvis(); // Récupérer les avis au chargement
  }

  Future<void> _fetchAvis() async {
    DocumentReference articleRef = widget.article['reference'];
    List<Map<String, dynamic>> avis = await _articleService.getAvis(articleRef);

    setState(() {
      widget.article['avis'] = avis.length; // Mettre à jour le nombre d'avis
      _avisList = avis; // Mettre à jour la liste des avis
    });
  }

  // Créer une instance du service
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Détails de l\'article',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            color: Color.fromARGB(255, 233, 233, 233),
            height: 0.1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Détails article',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: policeLato,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: const Color(0xFFFAFAFA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                (widget.article['photoUrl'] != null &&
                                        widget.article['photoUrl']!.isNotEmpty)
                                    ? NetworkImage(widget.article['photoUrl'])
                                    : const AssetImage('assets/prof.jpg')
                                        as ImageProvider,
                            radius: 20,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.article['praticienNom'] ?? 'Nom Inconnu',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  fontFamily: policeLato,
                                ),
                              ),
                              Text(
                                widget.article['createdAt'] != null
                                    ? formatDate(widget.article['createdAt'])
                                    : 'Date Inconnue',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontFamily: policeLato,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.article['description'] ?? 'Aucune description',
                        style: const TextStyle(
                          fontSize: 15,
                          fontFamily: policePoppins,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: widget.article['imageUrl'] != null &&
                                widget.article['imageUrl']!.isNotEmpty
                            ? Image.network(
                                widget.article['imageUrl']!,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${widget.article['avis'] ?? 0} avis',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  widget.article['likes']?.contains(FirebaseAuth
                                              .instance.currentUser?.uid) ==
                                          true
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final currentUserUid =
                                      FirebaseAuth.instance.currentUser!.uid;
                                  final likes = widget.article['likes'] ?? [];

                                  // Toggle le like
                                  if (likes.contains(currentUserUid)) {
                                    likes.remove(
                                        currentUserUid); // Enlever le like
                                  } else {
                                    likes
                                        .add(currentUserUid); // Ajouter le like
                                  }

                                  // Mettre à jour l'état local
                                  setState(() {
                                    widget.article['likes'] =
                                        likes; // Mettre à jour les likes
                                  });

                                  // Appeler le service pour mettre à jour Firestore
                                  await _articleService.toggleLike(
                                      widget.article['reference'].id,
                                      currentUserUid);
                                },
                              ),
                              const SizedBox(width: 5),
                              Text(
                                widget.article['likes']?.length.toString() ??
                                    '0',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
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

              // Ajout des avis statiques ici
              const SizedBox(height: 1), // Espacement avant la section des avis
              TextButton(
                onPressed: () {
                  setState(() {
                    _showAvis = !_showAvis; // Inverser l'état
                  });
                  if (_showAvis) {
                    _showAvisBottomSheet(); // Appeler la méthode pour afficher les avis
                  }
                },
                child: const Text(
                  'Afficher les avis',
                  style: TextStyle(
                    fontSize: 18,
                    color: couleurPrincipale,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(
                  height: 8), // Espacement entre le titre et les avis
              // Affichage conditionnel des avis
              if (_showAvis) _buildAvisSection(),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _avisController,
                decoration: InputDecoration(
                  hintText: 'Laissez un avis...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.send,
                color: couleurPrincipale,
              ),
              onPressed: () async {
                final commentaire = _avisController.text;
                // final praticienRef = await _articleService.getUserInfo();
                final userInfo = await _articleService
                    .getUserInfo(); // Récupère les infos du praticien ou du visiteur
                if (commentaire.isNotEmpty) {
                  print('Commentaire envoyé : $commentaire');

                  try {
                    // Vérifier le rôle de l'utilisateur pour déterminer quelle référence utiliser
                    DocumentReference userRef = userInfo['role'] == 'praticien'
                        ? userInfo['praticienRef']
                        : userInfo['visiteurRef'];

                    // Appeler la méthode pour poster l'avis
                    await _articleService.postAvis(
                        userRef, // Utilise la référence correcte
                        widget.article['reference'].id,
                        commentaire);
                    print('Avis posté avec succès.');
                    // Vider le champ après envoi
                    setState(() {
                      _avisController.clear();
                    });
                    //_fetchAvis pour mettre à jour la liste des avis
                    await _fetchAvis(); // Ajouter cette ligne
                  } catch (error) {
                    print('Erreur lors de l\'envoi de l\'avis : $error');
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvisSection() {
    if (_avisList.isEmpty) {
      return const Text('Aucun avis pour cet article.');
    }

    return ListView.builder(
    shrinkWrap: true,
    physics: const AlwaysScrollableScrollPhysics(), // Autorise le défilement
    itemCount: _avisList.length,
    itemBuilder: (context, index) {
      var avis = _avisList[index];
      return Card(
        color: Colors.grey,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: avis['profileImageUrl'] != null && avis['profileImageUrl']!.isNotEmpty
                    ? NetworkImage(avis['profileImageUrl']!)
                    : const AssetImage('assets/prof.jpg') as ImageProvider,
                radius: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      avis['firstName'] + ' ' + avis['lastName'] ?? 'Anonyme',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      avis['commentaire'] ?? 'Commentaire vide',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    // Optionnel : afficher la date de l'avis
                    Text(
                      formatDate(avis['createdAt']), // Assurez-vous d'avoir un champ de date
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  }
  

 void _showAvisBottomSheet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Permet un meilleur contrôle de la hauteur
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5, // Limite la hauteur à 50% de l'écran
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Avis des utilisateurs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: policeLato,
              ),
            ),
            const SizedBox(height: 8), // Espacement entre le titre et les avis
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: _avisList.map((avis) {
                    return Card(
                      color: couleurSecondaire,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: avis['profileImageUrl'] != null &&
                                      avis['profileImageUrl']!.isNotEmpty
                                  ? NetworkImage(avis['profileImageUrl']!)
                                  : const AssetImage('assets/prof.jpg')
                                      as ImageProvider,
                              radius: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    avis['firstName'] + ' ' + avis['lastName'] ?? 'Anonyme',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    avis['commentaire'] ?? 'Commentaire vide',
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                  // Optionnel : afficher la date de l'avis
                                  Text(
                                    formatDate(avis['createdAt']),
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      );
    },
  ).whenComplete(() {
    setState(() {
      _showAvis = false; // Réinitialise l'affichage des avis après fermeture
    });
  });
}
}

String formatDate(Timestamp timestamp) {
  final dateTime = timestamp.toDate();
  final difference = DateTime.now().difference(dateTime);
  if (difference.inDays > 0) {
    return 'posté il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
  } else if (difference.inHours > 0) {
    return 'posté il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
  } else if (difference.inMinutes > 0) {
    return 'posté il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
  } else {
    return 'posté à l\'instant';
  }
}
