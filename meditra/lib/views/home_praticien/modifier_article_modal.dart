import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:meditra/config/config.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:meditra/sevices/articles_services.dart';

class ModifierArticleModal extends StatefulWidget {
  final Map<String, dynamic> article; // Article à modifier
  
  const ModifierArticleModal({Key? key, required this.article}) : super(key: key);

  @override
  State<ModifierArticleModal> createState() => _ModifierArticleModalState();
}

class _ModifierArticleModalState extends State<ModifierArticleModal> {
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isPublishing = false; // Indicateur de chargement

  @override
  void initState() {
    super.initState();
    // Initialise les contrôleurs avec les données de l'article existant
    _titreController.text = widget.article['titre'];
    _descriptionController.text = widget.article['description'];
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? selectedImage = await _picker.pickImage(source: source);
    if (selectedImage != null) {
      setState(() {
        _imageFile = selectedImage;
      });
    }
  }

  // Fonction pour modifier l'article
  Future<void> _modifierArticle() async {
    if (_titreController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Le titre et la description doivent être remplis',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isPublishing = true; // Active l'animation de chargement
    });

    try {
      File? image;

      // Vérifie si une image a été sélectionnée
      if (_imageFile != null) {
        image = File(_imageFile!.path); // Convertir XFile en File si l'image est sélectionnée
      }

      // Appel du service pour modifier l'article avec ou sans image
      await ArticleService().modifierArticle(
        articleRef: widget.article['reference'], // Référence du document
        titre: _titreController.text,
        description: _descriptionController.text,
        imageFile: image, // Passe `null` si aucune image n'est sélectionnée
      );

      // Afficher un message de succès
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
                  padding: const EdgeInsets.all(16),
                  child: const Icon(
                    Icons.check,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Article Modifié avec succès',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Votre article a bien été mis à jour',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer le dialog de succès
                  Navigator.of(context).pop(); // Fermer le modal principal après
                },
                child: const Text(
                  'Fermer',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Erreur: $e',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    } finally {
      setState(() {
        _isPublishing = false; // Désactive l'animation de chargement
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        height: 500, // Ajuste la hauteur ici si nécessaire
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              // Titre du modal
              const Text(
                'Modifier un article',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Champ de texte pour le titre
              TextField(
                controller: _titreController,
                decoration: InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Champ de texte pour la description
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Boutons pour choisir une image
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library, color: couleurPrincipale),
                    label: const Text('Galerie'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: couleurSecondaire,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, color: couleurPrincipale),
                    label: const Text('Caméra'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: couleurSecondaire,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Affichage de l'image sélectionnée
              if (_imageFile != null)
                Image.file(
                  File(_imageFile!.path),
                  height: 150,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 20),

              // Bouton pour publier l'article
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isPublishing ? null : _modifierArticle, // Appel à la fonction de modification
                      style: ElevatedButton.styleFrom(
                        backgroundColor: couleurPrincipale,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isPublishing
                          ? LoadingAnimationWidget.newtonCradle(
                              color: Colors.white,
                              size: 30,
                            )
                          : const Text(
                              'Modifier l\'article',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),

           
              // Bouton pour annuler
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 224, 224, 224),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
