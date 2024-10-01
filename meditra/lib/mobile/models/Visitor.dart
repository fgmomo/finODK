class Visitor {
  String firstName;
  String lastName;
  String email;
  String password;

  Visitor({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });

  bool validate() {
    return firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty;
  }
}
