import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CrenauxService {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('crenaux');
      final FirebaseFirestore _db = FirebaseFirestore.instance;
       final FirebaseAuth auth = FirebaseAuth.instance; 

  // Ajouter un créneau
Future<void> addCrenau(String date, String heureDebut, String heureFin) async {
  try {
    // Obtenez l'ID de l'utilisateur connecté
    String? userId = auth.currentUser?.uid;

    // Vérifiez si l'utilisateur est connecté
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }

    // Vérifiez si les champs sont non vides
    if (date.isEmpty || heureDebut.isEmpty || heureFin.isEmpty) {
      throw Exception('Tous les champs doivent être remplis');
    }

    // Convertir les heures en format compatible (si nécessaire)
    // DateTime dateTimeStart = DateFormat('HH:mm').parse(heureDebut);
    // DateTime dateTimeEnd = DateFormat('HH:mm').parse(heureFin);

    // Ajout du créneau
    await _db.collection('crenaux').add({
      'date': date,
      'heure_debut': heureDebut,
      'heure_fin': heureFin,
      'praticien_id': userId,
      'status': 'disponible', // État par défaut
    });

  } catch (e) {
    print('Erreur lors de l\'ajout du créneau: $e'); // Affichez l'erreur
    throw Exception('Erreur lors de l\'ajout du créneau: ${e.toString()}'); // Lancez l'erreur
  }
}
// Récupérer les créneaux
Stream<List<Map<String, dynamic>>> getCrenaux() {
  // Obtenez l'ID de l'utilisateur connecté
  String? userId = auth.currentUser?.uid;

  // Vérifiez si l'utilisateur est connecté
  if (userId == null) {
    throw Exception('Utilisateur non connecté');
  }

  // Récupérer uniquement les créneaux où l'ID du praticien correspond à l'utilisateur connecté
  return collection
      .where('praticien_id', isEqualTo: userId) // Filtrer par praticien_id
      .snapshots()
      .map((snapshot) {
        final List<Map<String, dynamic>> crenaux = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'date': doc['date'],
            'time': '${doc['heure_debut']} - ${doc['heure_fin']}',
            'status': doc['status'],
          };
        }).toList();

        // Vérifier si la liste des créneaux est vide
        if (crenaux.isEmpty) {
          print('Aucun créneau disponible pour cet utilisateur.'); // Affichage dans la console
          // Vous pouvez également retourner un message ou un objet qui contient l'information
        }
        return crenaux;
      });
}

  // Supprimer un créneau

 // Méthode pour supprimer un créneau par son ID
  Future<void> removeCrenau(String id) async {
    try {
      // Accède au document par son ID et le supprime
      await collection.doc(id).delete();
      print('Créneau supprimé avec succès');
    } catch (e) {
      print('Erreur lors de la suppression du créneau: $e');
    }
  }
  // Modifier un créneau
Future<void> updateCrenau(String id, String date, String heureDebut, String heureFin) async {
  try {
    // Vérifiez si les champs sont non vides
    if (date.isEmpty || heureDebut.isEmpty || heureFin.isEmpty) {
      throw Exception('Tous les champs doivent être remplis');
    }

    // Mise à jour du créneau
    await collection.doc(id).update({
      'date': date,
      'heure_debut': heureDebut,
      'heure_fin': heureFin,
    });

    print('Créneau mis à jour avec succès');
  } catch (e) {
    print('Erreur lors de la mise à jour du créneau: $e');
    throw Exception('Erreur lors de la mise à jour du créneau: ${e.toString()}');
  }
}
}
