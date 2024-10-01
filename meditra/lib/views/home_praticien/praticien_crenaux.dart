import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';
import 'package:meditra/sevices/crenaux_service.dart';
import 'package:intl/intl.dart';

class PraticienCrenauxScreen extends StatefulWidget {
  const PraticienCrenauxScreen({super.key});

  @override
  State<PraticienCrenauxScreen> createState() => _PraticienCrenauxScreenState();
}

class _PraticienCrenauxScreenState extends State<PraticienCrenauxScreen> {
  final CrenauxService _crenauxService = CrenauxService();

  List<Map<String, dynamic>> _crenaux = [];

  @override
  void initState() {
    super.initState();
    _fetchCrenaux();
  }

  void _fetchCrenaux() {
    _crenauxService.getCrenaux().listen((crenaux) {
      setState(() {
        _crenaux = crenaux;
      });
    });
  }

void supprimerCrenau(String id) async {
  // Appelle la méthode pour supprimer le créneau dans le service
  await _crenauxService.removeCrenau(id);
  
  // Actualisez la liste des créneaux après suppression
  _fetchCrenaux(); 
}
  Future<void> _addCrenau(String date, String startTime, String endTime) async {
  print('Méthode _addCrenau appelée'); // Debug pour s'assurer que la méthode est bien appelée
  String? errorMessage; // Variable pour stocker les erreurs

  // Étape 1 : Vérifier que les champs ne sont pas vides
  if (date.isEmpty || startTime.isEmpty || endTime.isEmpty) {
    errorMessage = 'Tous les champs doivent être remplis';
    print(errorMessage); // Ajout du log
  } else {
    try {
      // Étape 2 : Convertir les chaînes de date et heure en objets DateTime pour la validation
      DateTime selectedDate = DateFormat('dd/MM/yyyy').parse(date); // Conversion de la date
      DateTime currentTime = DateTime.now(); // Date actuelle pour comparer avec selectedDate

      TimeOfDay start = TimeOfDay.fromDateTime(DateFormat('HH:mm').parse(startTime)); // Conversion heure de début
      TimeOfDay end = TimeOfDay.fromDateTime(DateFormat('HH:mm').parse(endTime)); // Conversion heure de fin

      // Étape 3 : Validation de la date et des heures

      // Validation 1 : La date ne doit pas être dans le passé
      if (selectedDate.isBefore(currentTime)) {
        errorMessage = 'La date ne peut pas être dans le passé';
        print(errorMessage); // Ajout du log
      }
      // Validation 2 : L'heure de début doit être avant l'heure de fin
      else if (start.hour > end.hour || (start.hour == end.hour && start.minute >= end.minute)) {
        errorMessage = 'L\'heure de début doit être avant l\'heure de fin';
        print('Heure de début: ${start.hour}:${start.minute}, Heure de fin: ${end.hour}:${end.minute}'); // Ajout du log pour vérifier les heures
        print(errorMessage); // Ajout du log
      }
    } catch (e) {
      // Si une erreur de parsing se produit (format incorrect)
      errorMessage = 'Format de date ou d\'heure invalide';
      print('Erreur de parsing : $e'); // Log de l'erreur de parsing
    }
  }

  // Étape 4 : Si une erreur est présente, afficher le message d'erreur
  if (errorMessage != null) {
    _showErrorDialog(errorMessage); // Fonction pour afficher l'erreur
  } else {
    // Si tout est correct, on passe à l'ajout du créneau
    try {
      await _crenauxService.addCrenau(date, startTime, endTime); // Appel du service pour ajouter le créneau
      print('Créneau ajouté avec succès');

      // Étape 5 : Fermer le modal après ajout réussi
      // Navigator.of(context).pop(); // Ferme le modal
    } catch (e) {
      // Gestion des erreurs lors de l'ajout du créneau
      print('Erreur lors de l\'ajout du créneau: $e');
      _showErrorDialog('Une erreur s\'est produite lors de l\'ajout du créneau');
    }
  }
}

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erreur'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      controller.text =
          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
    }
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      controller.text =
          "${pickedTime.hour}:${pickedTime.minute.toString().padLeft(2, '0')}";
    }
  }
void _showEditCrenauDialog(Map<String, dynamic> crenau) {
  TextEditingController dateController = TextEditingController(text: crenau['date']);
  TextEditingController startTimeController = TextEditingController(text: crenau['heure_debut']);
  TextEditingController endTimeController = TextEditingController(text: crenau['heure_fin']);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Center(
          child: Text(
            'Modifier le créneau',
            style: TextStyle(
              fontFamily: policePoppins,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        content: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Champ pour la date
              TextField(
                controller: dateController,
                decoration: InputDecoration(
                  hintText: 'Date (ex: 01/01/2024)',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
                onTap: () => _selectDate(context, dateController),
                readOnly: true,
              ),
              SizedBox(height: 10),
              // Champ pour l'heure de début
              TextField(
                controller: startTimeController,
                decoration: InputDecoration(
                  hintText: 'Heure de début (ex: 09:00)',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
                onTap: () => _selectTime(context, startTimeController),
                readOnly: true,
              ),
              SizedBox(height: 10),
              // Champ pour l'heure de fin
              TextField(
                controller: endTimeController,
                decoration: InputDecoration(
                  hintText: 'Heure de fin (ex: 11:00)',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
                onTap: () => _selectTime(context, endTimeController),
                readOnly: true,
              ),
            ],
          ),
        ),
        actions: [
          // Bouton Modifier
          Container(
            decoration: BoxDecoration(
              color: couleurPrincipale,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton(
              onPressed: () async {
                String date = dateController.text;
                String startTime = startTimeController.text;
                String endTime = endTimeController.text;

                if (date.isEmpty || startTime.isEmpty || endTime.isEmpty) {
                  _showErrorDialog('Tous les champs doivent être remplis');
                } else {
                  try {
                    await _crenauxService.updateCrenau(crenau['id'], date, startTime, endTime);
                    Navigator.of(context).pop(); // Ferme le modal après mise à jour
                  } catch (e) {
                    _showErrorDialog('Erreur lors de la mise à jour du créneau');
                  }
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Modifier'),
            ),
          ),
          SizedBox(height: 8),
          Center(
            child: Container(
              width: 300,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Annuler', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      );
    },
  );
}


  void _showAddCrenauDialog() {
    TextEditingController dateController = TextEditingController();
    TextEditingController startTimeController = TextEditingController();
    TextEditingController endTimeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Création de créneau',
              style: TextStyle(
                fontFamily: policePoppins,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Champ pour la date
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(
                    hintText: 'Date (ex: 01/01/2024)',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                    ),
                  ),
                  onTap: () => _selectDate(context, dateController),
                  readOnly: true,
                ),
                SizedBox(height: 10),
                // Champ pour l'heure de début
                TextField(
                  controller: startTimeController,
                  decoration: InputDecoration(
                    hintText: 'Heure de début (ex: 09:00)',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                    ),
                  ),
                  onTap: () => _selectTime(context, startTimeController),
                  readOnly: true,
                ),
                SizedBox(height: 10),
                // Champ pour l'heure de fin
                TextField(
                  controller: endTimeController,
                  decoration: InputDecoration(
                    hintText: 'Heure de fin (ex: 11:00)',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                    ),
                  ),
                  onTap: () => _selectTime(context, endTimeController),
                  readOnly: true,
                ),
              ],
            ),
          ),
          actions: [
            // Bouton Ajouter
            Container(
              decoration: BoxDecoration(
                color: couleurPrincipale,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: () async {
                  print('Bouton "Ajouter" cliqué');
                  String date = dateController.text;
                  String startTime = startTimeController.text;
                  String endTime = endTimeController.text;

                  if (date.isEmpty || startTime.isEmpty || endTime.isEmpty) {
                    print('Un ou plusieurs champs sont vides');
                    _showErrorDialog('Tous les champs doivent être remplis');
                  } else {
                    // Appelez _addCrenau uniquement si tous les champs sont remplis
                    await _addCrenau(date, startTime, endTime);
                    Navigator.of(context).pop();
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Ajouter'),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Container(
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Annuler',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: policePoppins,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Créneaux', style: TextStyle(fontFamily: 'Lato')),
        actions: [
          GestureDetector(
            onTap: _showAddCrenauDialog,
            child: Container(
              decoration: BoxDecoration(
                color: couleurPrincipale,
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body:
      _crenaux.isEmpty
        ? Center(
            child: Text(
              'Aucun créneau disponible.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          )
        :  ListView.builder(
        itemCount: _crenaux.length,
        itemBuilder: (context, index) {
          final crenau = _crenaux[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.black),
                          SizedBox(width: 5),
                          Text(
                            _crenaux[index]['date'],
                            style:
                                TextStyle(fontSize: 16, fontFamily: policeLato),
                          ),
                        ],
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                        decoration: BoxDecoration(
                          color: _crenaux[index]['status'] == 'Disponible'
                              ? const Color.fromARGB(255, 23, 90, 25)
                              : const Color.fromARGB(255, 170, 16, 5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _crenaux[index]['status'],
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: policePoppins,
                              fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.black),
                      SizedBox(width: 5),
                      Text(
                        _crenaux[index]['time'],
                        style: TextStyle(fontSize: 14, fontFamily: policeLato),
                      ),
                      Spacer(),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              // Logique pour modifier le créneau
                              _showEditCrenauDialog(crenau);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                             onPressed: () {
           String idDuCrenau = _crenaux[index]['id'];  // Récupérer l'ID du document à cet index
          supprimerCrenau(idDuCrenau);    // Passer l'ID du créneau à la fonction de suppression
        },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
