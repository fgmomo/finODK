import 'package:meditra/mobile/models/user.dart';
enum StatutPraticien {
  enAttente,
  approuve,
  rejete,
}

class Practitioner extends User {
  String biographie;
  String justificatif;
  StatutPraticien statut; // Utilise l'énumération

  Practitioner({
    required String prenom,
    required String nom,
    required String email,
    required String password,
    required String photo,
    required DateTime createdAt,
    required DateTime updatedAt,
    required this.biographie,
    required this.justificatif,
    this.statut = StatutPraticien.enAttente, // Statut par défaut
  }) : super(
          prenom: prenom,
          nom: nom,
          email: email,
          password: password,
          photo: photo,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
}