import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';

Future<void> showConfirmationModal(BuildContext context, VoidCallback onConfirm) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: _confirmationModalContent(context, onConfirm),
      );
    },
  );
}

Widget _confirmationModalContent(BuildContext context, VoidCallback onConfirm) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 10.0,
          offset: const Offset(0.0, 10.0),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min, // To make the modal compact
      children: <Widget>[
        // Icône en haut du modal
        Icon(
          Icons.delete_forever,
          color: Colors.redAccent,
          size: 60.0,
        ),
        SizedBox(height: 15.0),
        Text(
          "Confirmer la suppression",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: policeLato,
          ),
        ),
        SizedBox(height: 15.0),
        Text(
          "Êtes-vous sûr de vouloir supprimer cet article ?",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.0,
            fontFamily: policePoppins,
          ),
        ),
        SizedBox(height: 22.0),
        Align(
          alignment: Alignment.bottomRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Ferme le modal
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Ferme le modal
                  onConfirm(); // Exécute l'action de confirmation
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text("Supprimer"),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
