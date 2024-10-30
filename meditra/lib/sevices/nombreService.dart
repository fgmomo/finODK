import 'package:cloud_firestore/cloud_firestore.dart';

class ItemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Méthode pour récupérer le nombre d'items d'une collection spécifique
  Future<int> getItemCount(String collectionName) async {
    try {
      // Récupérer les documents de la collection spécifiée
      QuerySnapshot snapshot =
          await _firestore.collection(collectionName).get();
      return snapshot.docs.length; // Retourne le nombre de documents
    } catch (e) {
      print(
          'Erreur lors de la récupération des items de la collection $collectionName: $e');
      return 0; // Retourne 0 en cas d'erreur
    }
  }

  // Méthode pour récupérer le nombre de plantes
  Future<int> getPlantesCount() async {
    return await getItemCount("plantes");
  }

  // Méthode pour récupérer le nombre de maladies
  Future<int> getMaladiesCount() async {
    return await getItemCount("maladies");
  }

  // Méthode pour récupérer le nombre de remèdes
  Future<int> getRemedesCount() async {
    return await getItemCount("remede_maladie");
  }

  // Méthode pour récupérer le nombre de centres de pharmacopées
  Future<int> getCentresCount() async {
    return await getItemCount("centres");
  }

  // Méthode pour récupérer le nombre de praticiens actifs et approuvés
  Future<int> getPraticiensCount() async {
    try {
      // Récupérer les documents de la collection "praticiens"
      QuerySnapshot snapshot = await _firestore.collection("praticiens").get();

      // Filtrer les praticiens pour compter ceux qui sont actifs et approuvés
      int count = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['isActive'] == true && data['status'] == 'approuvé';
      }).length;

      return count; // Retourner le nombre filtré
    } catch (e) {
      print('Erreur lors de la récupération des praticiens: $e');
      return 0; // Retourne 0 en cas d'erreur
    }
  }

  // Méthode pour récupérer le nombre d'utilisateurs (visiteurs)
  Future<int> getVisiteursCount() async {
    try {
      // Récupérer les documents de la collection "praticiens"
      QuerySnapshot snapshot = await _firestore.collection("visiteurs").get();

      // Filtrer les praticiens pour compter ceux qui sont actifs et approuvés
      int count = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['isActive'] == true;
      }).length;

      return count; // Retourner le nombre filtré
    } catch (e) {
      print('Erreur lors de la récupération des visiteurs: $e');
      return 0; // Retourne 0 en cas d'erreur
    }
  }

  // Méthode pour récupérer le nombre d'administrateurs
  Future<int> getAdministrateursCount() async {
    return await getItemCount("admin");
  }
}
