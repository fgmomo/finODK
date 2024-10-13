import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';
import 'package:meditra/views/home_praticien/praticien_crenaux.dart';
import 'package:meditra/views/home_praticien/praticien_k_articles.dart';

class PraticienArticleScreen extends StatefulWidget {
  const PraticienArticleScreen({super.key});

  @override
  State<PraticienArticleScreen> createState() => _PraticienArticleScreenState();
}

class _PraticienArticleScreenState extends State<PraticienArticleScreen>
    with SingleTickerProviderStateMixin {
  // Exemple d'articles (vous pouvez remplacer cette liste par des données dynamiques)
  final List<Map<String, dynamic>> articles = [
    {
      'praticienNom': 'Dr. Alice Dupont',
      'postDate': '12 Oct 2024',
      'description': 'Cet article discute des dernières découvertes en cardiologie.',
      'imageUrl': 'assets/gingebre2.jpg',
      'photoUrl': 'assets/prof.jpg',
      'avis': 45,
      'likes': 120
    },
    {
      'praticienNom': 'Dr. Marc Durand',
      'postDate': '10 Oct 2024',
      'description': 'Une analyse approfondie des traitements alternatifs pour les migraines.',
      'imageUrl': 'assets/thym.png',
      'photoUrl': 'assets/prof.jpg',
      'avis': 30,
      'likes': 80
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Articles',
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
            icon: const Icon(
              Icons.notifications,
              color: couleurPrincipale,
              size: 35,
            ),
            onPressed: () {
              // Logique de notification
            },
            padding: const EdgeInsets.all(10),
            tooltip: 'Notifications',
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            color: Color.fromARGB(255, 233, 233, 233),
            height: 0.1,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PraticienMesArticleScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.remove_red_eye, color: Colors.white),
                  label: const Text(
                    'Mes articles',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: couleurPrincipale,
                    padding: const EdgeInsets.symmetric(
                        vertical: 13, horizontal: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            color: Colors.grey,
            thickness: 0.5,
            indent: 16,
            endIndent: 18,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                var article = articles[index];
                return Column(
                  children: [
                    Card(
                      color: const Color(0xFFFAFAFA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icone du praticien
                                CircleAvatar(
                                  backgroundImage:
                                      AssetImage(article['photoUrl']),
                                  radius: 20,
                                ),
                                const SizedBox(width: 10),
                                // Nom du praticien et date de publication
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      article['praticienNom'],
                                      style: const TextStyle(
                                        fontFamily: policeLato,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      article['postDate'],
                                      style: const TextStyle(
                                        fontFamily: policeLato,
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Description de l'article
                            Text(
                              article['description'].length > 100
                                  ? '${article['description'].substring(0, 100)}...'
                                  : article['description'],
                              style: const TextStyle(fontSize: 15,fontFamily: policeLato,),
                            ),
                            const SizedBox(height: 10),
                            // Image de l'article
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                article['imageUrl'],
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Section avis et likes
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${article['avis']} avis',
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
                    const Divider(
                      color: Colors.grey,
                      thickness: 0.5,
                      indent: 16,
                      endIndent: 18,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
