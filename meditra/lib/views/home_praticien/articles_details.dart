import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Map<String, dynamic> article;

  const ArticleDetailScreen({Key? key, required this.article})
      : super(key: key);

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
                            backgroundImage: (article['photoUrl'] != null &&
                                    article['photoUrl']!.isNotEmpty)
                                ? NetworkImage(article['photoUrl'])
                                : const AssetImage('assets/prof.jpg')
                                    as ImageProvider,
                            radius: 20,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article['praticienNom'] ?? 'Nom Inconnu',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  fontFamily: policeLato,
                                ),
                              ),
                              Text(
                                article['createdAt'] != null
                                    ? formatDate(article['createdAt'])
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
                        article['description'] ?? 'Aucune description',
                        style: const TextStyle(
                          fontSize: 15,
                          fontFamily: policePoppins,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: article['imageUrl'] != null &&
                                article['imageUrl']!.isNotEmpty
                            ? Image.network(
                                article['imageUrl']!,
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
                            '${article['avis'] ?? 0} avis',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.favorite_border,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                article['likes'].toString(),
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
              const SizedBox(height: 16), // Espacement avant la section des avis
              Text(
                'Avis des utilisateurs',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: policeLato,
                ),
              ),
              const SizedBox(height: 8), // Espacement entre le titre et les avis
              _buildStaticReviews(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStaticReviews() {
    // Liste d'avis statiques
    final List<Map<String, String>> reviews = [
      {
        'userName': 'Alice Dupont',
        'message': 'Un article très informatif et bien écrit.',
        'userPhoto': 'https://example.com/photo1.jpg',
      },
      {
        'userName': 'Jean Martin',
        'message': 'J\'ai beaucoup appris grâce à cet article !',
        'userPhoto': 'https://example.com/photo2.jpg',
      },
      {
        'userName': 'Marie Curie',
        'message': 'Les informations étaient claires et précises.',
        'userPhoto': 'https://example.com/photo3.jpg',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        var review = reviews[index];
        return Card(
          color: couleurSecondaire,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: review['userPhoto'] != null && review['userPhoto']!.isNotEmpty
                      ? NetworkImage(review['userPhoto']!)
                      : const AssetImage('assets/prof.jpg') as ImageProvider,
                  radius: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review['userName'] ?? 'Nom Inconnu',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: couleurPrincipale,
                          fontSize: 13,
                          fontFamily: policePoppins,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        review['message'] ?? 'Aucun message',
                        style: const TextStyle(fontSize: 10,fontFamily: policePoppins),
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
}
