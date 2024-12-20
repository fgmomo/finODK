import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';
import 'package:meditra/sevices/articles_services.dart';
import 'package:meditra/views/home_praticien/articles_details.dart';
import 'package:meditra/views/home_praticien/modifier_article_modal.dart';
import 'package:meditra/views/home_praticien/publier_article_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditra/views/home_praticien/suppression_article_modal.dart';

class PraticienMesArticleScreen extends StatefulWidget {
  final Map<String, dynamic>? article;

  const PraticienMesArticleScreen({super.key, this.article});

  @override
  State<PraticienMesArticleScreen> createState() =>
      _PraticienMesArticleScreenState();
}

class _PraticienMesArticleScreenState extends State<PraticienMesArticleScreen> {
  final ArticleService _articleService = ArticleService();

  @override
  void initState() {
    super.initState();
  }

  // Fonction async pour récupérer les avis
  Future<int> _getAvisCount(DocumentReference articleRef) async {
    List<Map<String, dynamic>> avis = await _articleService.getAvis(articleRef);
    return avis.length;
  }

  Stream<List<Map<String, dynamic>>> _streamArticles() {
    return _articleService.streamArticlesByPraticienId();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Articles',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.playlist_add,
              color: couleurPrincipale,
              size: 35,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const PublierArticleModal();
                },
              );
            },
            tooltip: 'Ajouter un article',
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un article...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
            child: Text(
              'Mes articles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _articleService.streamArticlesByPraticienId(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Erreur: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Aucun article trouvé."));
                } else {
                  final articles = snapshot.data!;
                  return ListView.builder(
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      var article = articles[index];
                      var articleRef = article['reference'];
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ArticleDetailScreen(article: article),
                                ),
                              );
                            },
                            child: Card(
                              color: const Color(0xFFFAFAFA),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundImage:
                                                  (article['photoUrl'] !=
                                                              null &&
                                                          article['photoUrl']!
                                                              .isNotEmpty)
                                                      ? NetworkImage(
                                                          article['photoUrl'])
                                                      : const AssetImage(
                                                              'assets/prof.jpg')
                                                          as ImageProvider,
                                              radius: 20,
                                            ),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  article['praticienNom'] ??
                                                      'Nom Inconnu',
                                                  style: const TextStyle(
                                                    fontFamily: policeLato,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Text(
                                                  article['createdAt'] != null
                                                      ? formatDate(
                                                          article['createdAt']
                                                              as Timestamp)
                                                      : 'Date Inconnue',
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
                                        Text(
                                          article['description']?.length > 100
                                              ? '${article['description']!.substring(0, 100)}...'
                                              : article['description'] ??
                                                  'Aucune description',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontFamily: policeLato,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: article['imageUrl'] != null &&
                                                  article['imageUrl']!
                                                      .isNotEmpty
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
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Icon(
                                                    Icons.image,
                                                    size: 50,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(height: 10),
                                        FutureBuilder<int>(
                                          future: _getAvisCount(articleRef),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const CircularProgressIndicator();
                                            } else if (snapshot.hasError) {
                                              return Text(
                                                  "Erreur: ${snapshot.error}");
                                            } else {
                                              return Text(
                                                '${snapshot.data} avis',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    article['likes']?.contains(
                                                                FirebaseAuth
                                                                    .instance
                                                                    .currentUser
                                                                    ?.uid) ==
                                                            true
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () async {
                                                    await _articleService
                                                        .toggleLike(
                                                            article['reference']
                                                                .id,
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid);
                                                  },
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  article['likes']
                                                          ?.length
                                                          .toString() ??
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
                                  Positioned(
                                    right: 0,
                                    child: PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert),
                                      onSelected: (value) {
                                        if (value == 'Modifier') {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return ModifierArticleModal(
                                                  article: article);
                                            },
                                          );
                                        } else if (value == 'Supprimer') {
                                          showConfirmationModal(context,
                                              () async {
                                            DocumentReference articleRef =
                                                article['reference'];
                                            String? imageUrl =
                                                article['imageUrl'];
                                            await ArticleService()
                                                .supprimerArticle(
                                                    articleRef: articleRef,
                                                    imageUrl: imageUrl);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Article supprimé avec succès')),
                                            );
                                          });
                                        }
                                      },
                                      itemBuilder: (BuildContext context) =>
                                          <PopupMenuEntry<String>>[
                                        const PopupMenuItem<String>(
                                          value: 'Modifier',
                                          child: Text('Modifier'),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'Supprimer',
                                          child: Text('Supprimer'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(thickness: 1),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
