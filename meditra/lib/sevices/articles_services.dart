import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArticleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Publier un article
  Future<void> publierArticle({
    required String titre,
    required String description,
    File? imageFile, // L'image est maintenant facultative (nullable)
  }) async {
    try {
      // Récupérer l'ID de l'utilisateur connecté (praticien)
      String? praticienId = FirebaseAuth.instance.currentUser?.uid;

      if (praticienId == null) {
        throw Exception("Utilisateur non connecté");
      }

      String? imageUrl;
      // Étape 1 : Si une image est fournie, la téléverser dans Firebase Storage
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile);
      }

      // Étape 2 : Enregistrer l'article dans Firestore
      await _firestore.collection('articles').add({
        'titre': titre,
        'description': description,
        'imageUrl': imageUrl ??
            '', // Ajouter l'URL de l'image ou une chaîne vide si non fournie
        'praticienId': praticienId, // Référence au praticien connecté
        'status': 'en attente', // Statut initial
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      print("Erreur lors de la publication de l'article: $e");
      rethrow;
    }
  }

  // Fonction pour téléverser l'image et obtenir l'URL
  Future<String> _uploadImage(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      Reference storageRef = _storage.ref().child('articles_images/$fileName');
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Erreur lors du téléversement de l'image: $e");
      throw e;
    }
  }

  // Nouvelle méthode pour récupérer tous les articles d'un praticien via un Stream
Stream<List<Map<String, dynamic>>> streamArticlesByPraticienId() async* {
  try {
    // Récupérer l'ID du praticien connecté
    String? praticienId = FirebaseAuth.instance.currentUser?.uid;
    if (praticienId == null) {
      throw Exception("Utilisateur non connecté");
    }

    // Interroger Firestore pour récupérer les articles via un Stream
    Stream<QuerySnapshot> articlesSnapshotStream = _firestore
        .collection('articles')
        .where('praticienId', isEqualTo: praticienId)
        .snapshots();

    await for (QuerySnapshot articlesSnapshot in articlesSnapshotStream) {
      List<Map<String, dynamic>> articles = [];

      // Récupérer les articles et les détails des praticiens associés
      for (var articleDoc in articlesSnapshot.docs) {
        Map<String, dynamic> articleData =
            articleDoc.data() as Map<String, dynamic>;

        // Ajoutez la référence au document dans l'article
        articleData['reference'] = articleDoc.reference;

        // Récupérer le praticienId pour faire une requête sur la collection des praticiens
        String praticienIdFromArticle = articleData['praticienId'];

        // Récupérer le document du praticien
        DocumentSnapshot praticienDoc = await _firestore
            .collection('praticiens')
            .doc(praticienIdFromArticle)
            .get();

        if (praticienDoc.exists) {
          Map<String, dynamic> praticienData =
              praticienDoc.data() as Map<String, dynamic>;

          // Ajouter les informations du praticien à l'article
          articleData['praticienNom'] =
              '${praticienData['firstName']} ${praticienData['lastName']}';
          articleData['photoUrl'] = praticienData['photoUrl'];
        }

        // Ajouter l'article à la liste
        articles.add(articleData);
      }

      yield articles; // Émettre les articles via le Stream
    }
  } catch (e) {
    print("Erreur lors de la récupération des articles: $e");
    yield []; // Retourner une liste vide en cas d'erreur
  }
}

//Tous les articles
Stream<List<Map<String, dynamic>>> streamAllArticles() async* {
  try {
    // Interroger Firestore pour récupérer tous les articles via un Stream
    Stream<QuerySnapshot> articlesSnapshotStream = _firestore
        .collection('articles')
        .snapshots();

    await for (QuerySnapshot articlesSnapshot in articlesSnapshotStream) {
      List<Map<String, dynamic>> articles = [];

      // Récupérer les articles et les détails des praticiens associés
      for (var articleDoc in articlesSnapshot.docs) {
        Map<String, dynamic> articleData =
            articleDoc.data() as Map<String, dynamic>;

        // Ajouter la référence au document dans l'article
        articleData['reference'] = articleDoc.reference;

        // Récupérer le praticienId pour faire une requête sur la collection des praticiens
        String praticienIdFromArticle = articleData['praticienId'];

        // Récupérer le document du praticien
        DocumentSnapshot praticienDoc = await _firestore
            .collection('praticiens')
            .doc(praticienIdFromArticle)
            .get();

        if (praticienDoc.exists) {
          Map<String, dynamic> praticienData =
              praticienDoc.data() as Map<String, dynamic>;

          // Ajouter les informations du praticien à l'article
          articleData['praticienNom'] =
              '${praticienData['firstName']} ${praticienData['lastName']}';
          articleData['photoUrl'] = praticienData['photoUrl'];
        }

        // Ajouter l'article à la liste
        articles.add(articleData);
      }

      yield articles; // Émettre les articles via le Stream
    }
  } catch (e) {
    print("Erreur lors de la récupération des articles: $e");
    yield []; // Retourner une liste vide en cas d'erreur
  }
}



  // Nouvelle méthode pour modifier un article en utilisant la référence du document
  Future<void> modifierArticle({
    required DocumentReference articleRef,
    required String titre,
    required String description,
    File? imageFile,
  }) async {
    try {
      // Préparer les données à mettre à jour
      Map<String, dynamic> updatedData = {
        'titre': titre,
        'description': description,
      };

      // Si une nouvelle image est fournie, téléversez-la et mettez à jour l'URL
      if (imageFile != null) {
        String imageUrl = await _uploadImage(imageFile);
        updatedData['imageUrl'] = imageUrl; // Mettez à jour l'URL de l'image
      }

      // Mettre à jour l'article dans Firestore
      await articleRef.update(updatedData);
    } catch (e) {
      print("Erreur lors de la modification de l'article: $e");
      rethrow;
    }
  }


  // Méthode pour supprimer un article
  Future<void> supprimerArticle({required DocumentReference articleRef, String? imageUrl}) async {
    try {
      // Si l'article contient une image, supprimer l'image de Firebase Storage
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await _supprimerImage(imageUrl);
      }
      // Supprimer l'article de Firestore
      await articleRef.delete();
    } catch (e) {
      print("Erreur lors de la suppression de l'article: $e");
      rethrow;
    }
  }
  // Méthode pour supprimer une image de Firebase Storage
  Future<void> _supprimerImage(String imageUrl) async {
    try {
      // Créer une référence à l'image dans Firebase Storage
      Reference storageRef = _storage.refFromURL(imageUrl);

      // Supprimer l'image
      await storageRef.delete();
    } catch (e) {
      print("Erreur lors de la suppression de l'image: $e");
      throw e;
    }
  }


  // Méthode pour ajouter un like
Future<void> toggleLike(String articleId, String userId) async {
  try {
    DocumentReference articleRef = _firestore.collection('articles').doc(articleId);

    // Récupérer l'article
    DocumentSnapshot articleSnapshot = await articleRef.get();
    if (!articleSnapshot.exists) return;

    Map<String, dynamic> articleData = articleSnapshot.data() as Map<String, dynamic>;
    List<dynamic> likes = List<dynamic>.from(articleData['likes'] ?? []); // Utiliser List<dynamic>.from pour s'assurer que c'est une liste

    // Vérifiez si l'utilisateur a déjà liké l'article
    if (likes.contains(userId)) {
      // Si oui, le retirer
      likes.remove(userId);
    } else {
      // Sinon, l'ajouter
      likes.add(userId);
    }

    // Mettre à jour l'article avec la nouvelle liste de likes
    await articleRef.update({'likes': likes});
  } catch (e) {
    print("Erreur lors de la gestion des likes: $e");
    rethrow; // Relancer l'exception pour le gestionnaire d'erreurs
  }
}




  // Méthode pour récupérer les informations de l'utilisateur connecté
  Future<Map<String, dynamic>> getUserInfo() async {
    User? user = _auth.currentUser;

    if (user == null) {
      throw Exception("Utilisateur non connecté");
    }

    // Chercher dans la collection 'praticiens' en utilisant la référence de document
    DocumentSnapshot praticienDoc = await _firestore.collection('praticiens').doc(user.uid).get();

    if (praticienDoc.exists) {
      Map<String, dynamic> praticienData = praticienDoc.data() as Map<String, dynamic>;
      return {
        'firstName': praticienData['firstName'],
        'lastName': praticienData['lastName'],
        'profileImageUrl': praticienData['photoUrl'], // champ spécifique à praticiens
        'role': 'praticien',
        'praticienRef': praticienDoc.reference, // Référence du praticien
      };
    } else {
      // Chercher dans la collection 'visiteurs' en utilisant la référence de document
      DocumentSnapshot visiteurDoc = await _firestore.collection('visiteurs').doc(user.uid).get();

      if (visiteurDoc.exists) {
        Map<String, dynamic> visiteurData = visiteurDoc.data() as Map<String, dynamic>;
        return {
          'firstName': visiteurData['firstName'],
          'lastName': visiteurData['lastName'],
          'profileImageUrl': visiteurData['profileImageUrl'], // champ spécifique à visiteurs
          'role': 'visiteur',
          'visiteurRef': visiteurDoc.reference, // Référence du visiteur
        };
      } else {
        throw Exception("Utilisateur non trouvé dans les collections 'praticiens' ou 'visiteurs'");
      }
    }
  }

  // Méthode pour poster un avis sur un article
  Future<void> postAvis(DocumentReference  userRef, String articleId, String commentaire) async {
    // Récupérer les informations de l'utilisateur connecté (praticien ou visiteur)
    Map<String, dynamic> userInfo = await getUserInfo();

    // Préparer les données de l'avis
    Map<String, dynamic> avisData = {
     'userRef': userRef, // Référence du praticien ou du visiteur
      'firstName': userInfo['firstName'],
      'lastName': userInfo['lastName'],
      'profileImageUrl': userInfo['profileImageUrl'],
       'role': userInfo['role'], // Enregistre le rôle (praticien ou visiteur)
      'commentaire': commentaire,
      'createdAt': FieldValue.serverTimestamp(),
    };

    // Ajouter l'avis dans une sous-collection 'avis' de l'article
    await _firestore.collection('articles').doc(articleId).collection('avis').add(avisData);
  }

  Future<List<Map<String, dynamic>>> getAvis(DocumentReference articleRef) async {
  final QuerySnapshot avisSnapshot = await articleRef.collection('avis')
      .orderBy('createdAt', descending: true) 
      .get();

  return avisSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
}
}
