  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/material.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:image_picker/image_picker.dart';
  import 'dart:io';
  import 'package:firebase_storage/firebase_storage.dart';
  import 'package:meditra/config/config.dart';

  class RegisterPraticienScreen extends StatefulWidget {
    @override
    _RegisterPraticienScreenState createState() =>
        _RegisterPraticienScreenState();
  }

  class _RegisterPraticienScreenState extends State<RegisterPraticienScreen> {
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final TextEditingController professionalNumberController =
        TextEditingController();
    final TextEditingController justificationController = TextEditingController();

    int _currentStep = 0;
    String? errorMessage;

    File? _selectedPhoto; // Pour stocker la photo sélectionnée
    File?
        _selectedJustificatifPhoto; // Pour stocker la photo justificatif sélectionnée

    final ImagePicker _picker =
        ImagePicker(); // Initialiser le sélecteur d'images

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          title: Text('Inscription Praticien'),
          backgroundColor: Colors.white,
        ),
        body: Column(
          children: [
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red, fontFamily: 'Poppins'),
                ),
              ),
            Expanded(
              child: Stepper(
                currentStep: _currentStep,
                onStepContinue: _nextStep,
                onStepCancel: _previousStep,
                steps: getSteps(),
                type: StepperType.vertical,
              ),
            ),
          ],
        ),
      );
    }

    void _showSuccessDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  padding: EdgeInsets.all(16),
                  child: Icon(
                    Icons.check,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Inscription réussie',
                  style: TextStyle(
                    fontFamily: policePoppins,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: couleurPrincipale,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Merci pour votre inscription ! Nous avons reçu vos informations et nous les examinerons bientôt. Vous serez informé de l\'état de votre inscription.',
                  style: TextStyle(
                    fontFamily: policePoppins,
                    fontSize: 15,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pop(context); // Ferme le dialog et le screen
                  },
                  child: Text(
                    'Fermer',
                    style: TextStyle(
                      fontFamily: policePoppins,
                      color: couleurPrincipale,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    List<Step> getSteps() => [
          Step(
            title: Text('Informations personnelles'),
            content: _buildPersonalInformationStep(),
            isActive: _currentStep >= 0,
            state: _currentStep == 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: Text('Informations professionnelles'),
            content: _buildProfessionalInformationStep(),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: Text('Confirmation'),
            content: _buildConfirmationSummary(),
            isActive: _currentStep >= 2,
            state: _currentStep == 2 ? StepState.complete : StepState.indexed,
          ),
        ];

    Widget _buildPersonalInformationStep() {
      return Column(
        children: [
          _buildTextField(firstNameController, 'Prénom'),
          _buildTextField(lastNameController, 'Nom'),
          _buildTextField(emailController, 'Email'),
          _buildPasswordField(passwordController, 'Mot de passe'),
          _buildPasswordField(
              confirmPasswordController, 'Confirmez le mot de passe'),
          _buildUploadButton("Télécharger une photo de profil", _pickImage),
          if (_selectedPhoto != null) Text('Photo de profil sélectionnée'),
        ],
      );
    }

    Widget _buildProfessionalInformationStep() {
      return Column(
        children: [
          _buildTextField(addressController, 'Adresse professionnelle'),
          _buildTextField(professionalNumberController, 'Numéro professionnel'),
          _buildUploadButton(
              "Uploader une photo justificatif", _pickJustificatifImage),
          if (_selectedJustificatifPhoto != null)
            Text('Photo justificatif sélectionnée'),
          _buildMultilineTextField(
              justificationController, 'Pourquoi voulez-vous rejoindre ?'),
        ],
      );
    }

    Widget _buildTextField(TextEditingController controller, String label) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(fontFamily: 'Poppins'),
            border: OutlineInputBorder(),
          ),
        ),
      );
    }

    Widget _buildPasswordField(TextEditingController controller, String label) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(fontFamily: 'Poppins'),
            border: OutlineInputBorder(),
          ),
        ),
      );
    }

    Widget _buildMultilineTextField(
        TextEditingController controller, String label) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(fontFamily: 'Poppins'),
            border: OutlineInputBorder(),
          ),
        ),
      );
    }

    Widget _buildUploadButton(String text, VoidCallback onPressed) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: couleurPrincipale,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    }

    Widget _buildConfirmationSummary() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Récapitulatif des informations :',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text('Prénom: ${firstNameController.text}'),
          Text('Nom: ${lastNameController.text}'),
          Text('Email: ${emailController.text}'),
          Text('Adresse professionnelle: ${addressController.text}'),
          Text('Numéro professionnel: ${professionalNumberController.text}'),
          Text('Justification: ${justificationController.text}'),
          if (_selectedPhoto != null)
            Text('Photo de profil: ${_selectedPhoto!.path.split('/').last}'),
          if (_selectedJustificatifPhoto != null)
            Text(
                'Photo justificatif: ${_selectedJustificatifPhoto!.path.split('/').last}'),
        ],
      );
    }

    void _nextStep() {
      // Validation de chaque étape
      if (_currentStep == 0) {
        if (_validatePersonalInfo()) {
          setState(() {
            _currentStep += 1;
          });
        }
      } else if (_currentStep == 1) {
        if (_validateProfessionalInfo()) {
          setState(() {
            _currentStep += 1;
          });
        }
      } else if (_currentStep == 2) {
        register();
      }
    }

    void _previousStep() {
      if (_currentStep > 0) {
        setState(() {
          _currentStep -= 1;
        });
      }
    }

    bool _validatePersonalInfo() {
      if (firstNameController.text.isEmpty ||
          lastNameController.text.isEmpty ||
          emailController.text.isEmpty ||
          passwordController.text.isEmpty ||
          confirmPasswordController.text.isEmpty ||
          _selectedPhoto == null) {
        setState(() {
          errorMessage =
              "Tous les champs doivent être remplis et une photo doit être uploadée.";
        });
        return false;
      }
      if (passwordController.text != confirmPasswordController.text) {
        setState(() {
          errorMessage = "Les mots de passe ne correspondent pas.";
        });
        return false;
      }
      errorMessage = null; // Reset error message if validation passes
      return true;
    }

    bool _validateProfessionalInfo() {
      if (addressController.text.isEmpty ||
          professionalNumberController.text.isEmpty ||
          _selectedJustificatifPhoto == null ||
          justificationController.text.isEmpty) {
        setState(() {
          errorMessage =
              "Tous les champs doivent être remplis et le justificatif doit être uploadé.";
        });
        return false;
      }
      errorMessage = null; // Reset error message if validation passes
      return true;
    }

    Future<void> _pickImage() async {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedPhoto = File(pickedFile.path);
        });
      }
    }

    Future<void> _pickJustificatifImage() async {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedJustificatifPhoto = File(pickedFile.path);
        });
      }
    }
 Future<void> register() async {
   try {
      // Crée un nouvel utilisateur avec Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text,
              password: passwordController.text);

      // Initialisez les URLs à null
      String? photoUrl;
      String? justificatifUrl;

      // Upload de la photo de profil
      if (_selectedPhoto != null) {
        photoUrl = await _uploadFile(_selectedPhoto!, 'photos_profil/${userCredential.user?.uid}');
      }

      // Upload du justificatif
      if (_selectedJustificatifPhoto != null) {
        justificatifUrl = await _uploadFile(_selectedJustificatifPhoto!, 'justificatifs/${userCredential.user?.uid}');
      }

      // Enregistrer dans Firestore
      await FirebaseFirestore.instance.collection('praticiens').doc(userCredential.user?.uid).set({
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'email': emailController.text,
        'address': addressController.text,
        'professionalNumber': professionalNumberController.text,
        'justification': justificationController.text,
        'photoUrl': photoUrl,
        'justificatifUrl': justificatifUrl,
         'role': 'praticien',
        'status': 'en attente',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(), // Ajout d'un timestamp pour suivi
      });

      // Affiche le message de succès
      _showSuccessDialog(context);
   } catch (e) {
      setState(() {
        errorMessage = "Erreur lors de l'inscription : ${e.toString()}";
      });
   }
}

  
  Future<String?> _uploadFile(File file, String path) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      final uploadTask = await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Erreur lors du téléchargement de l'image : $e");
      return null;
    }
  }

    void _resetFields() {
      firstNameController.clear();
      lastNameController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      addressController.clear();
      professionalNumberController.clear();
      justificationController.clear();
      _selectedPhoto = null;
      _selectedJustificatifPhoto = null;
      _currentStep = 0;
    }
  }
