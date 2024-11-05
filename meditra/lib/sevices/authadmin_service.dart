import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthAdminService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Méthode pour créer un administrateur par défaut au démarrage
  Future<void> createDefaultAdmin() async {
    try {
      CollectionReference adminCollection = _firestore.collection('admin');

      // Vérifier s'il existe déjà un admin
      QuerySnapshot querySnapshot = await adminCollection.get();
      if (querySnapshot.docs.isEmpty) {
        // Aucun admin trouvé, en créer un par défaut
        String defaultEmail = "admin@gmail.com";
        String defaultPassword = "123456";  // A changer pour un mot de passe plus sécurisé

        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: defaultEmail,
          password: defaultPassword,
        );

        // Ajouter les informations de l'admin dans Firestore
        await adminCollection.doc(userCredential.user!.uid).set({
          'firstName': 'Adama',
          'lastName': 'Guindo',
          'email': defaultEmail,
          'isActive': true,
        });
        print("Admin par défaut créé avec succès.");
      } else {
        print("Un admin existe déjà.");
      }
    } catch (e) {
      print("Erreur lors de la création de l'admin par défaut : $e");
    }
  }

  // Méthode pour gérer la connexion des admins
  Future<User?> loginAdmin(String email, String password) async {
    try {
      // Authentification avec Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Vérifier si l'utilisateur est bien un admin dans Firestore
      DocumentSnapshot adminSnapshot = await _firestore
          .collection('admin')
          .doc(userCredential.user!.uid)
          .get();

      if (adminSnapshot.exists) {
        print("Connexion réussie.");
        return userCredential.user;  // Retourner l'utilisateur connecté
      } else {
        print("Cet utilisateur n'est pas un admin.");
        return null;
      }
    } catch (e) {
      print("Erreur de connexion : $e");
      return null;
    }
  }

   // Méthode pour récupérer tous les administrateurs
  Future<List<Map<String, String>>> getAllAdmins() async {
  try {
    CollectionReference adminCollection = _firestore.collection('admin');
    QuerySnapshot querySnapshot = await adminCollection.get();

    List<Map<String, String>> admins = [];
    for (var doc in querySnapshot.docs) {
      admins.add({
        'uid': doc.id, // Ajout de l'ID de l'administrateur
        'nom': doc['lastName'] ?? 'Nom indisponible', // Gérer les valeurs nulles
        'prenom': doc['firstName'] ?? 'Prénom indisponible',
        'email': doc['email'] ?? 'Email indisponible',
      
      });
    }
    return admins;
  } catch (e) {
    print("Erreur lors de la récupération des administrateurs : $e");
    return [];
  }
}
 // Méthode pour ajouter un administrateur
Future<String?> addAdmin(String firstName, String lastName, String email, String password) async {
  try {
    // Créer l'utilisateur dans Firebase Auth
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Ajouter les informations de l'admin dans Firestore
    await _firestore.collection('admin').doc(userCredential.user!.uid).set({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    });
    print('Administrateur ajouté avec succès.');
    return null; // Aucune erreur
  } catch (e) {
    // Renvoie l'erreur sous forme de chaîne
    return e.toString();
  }
}

  // Méthode pour charger les administrateurs (ajoutée)
  Future<List<Map<String, String>>> loadAdmins() async {
    return await getAllAdmins();
  }
}
