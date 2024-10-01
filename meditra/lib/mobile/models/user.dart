class User {
  String prenom;
  String nom;
  String email;
  String password;
  String photo;
  DateTime createdAt;
  DateTime updatedAt;

  User({
    required this.prenom,
    required this.nom,
    required this.email,
    required this.password,
    required this.photo,
    required this.createdAt,
    required this.updatedAt,
  });
}
