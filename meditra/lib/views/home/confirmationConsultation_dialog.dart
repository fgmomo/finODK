import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';

class ConfirmationDialog1 extends StatelessWidget {

  const ConfirmationDialog1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            'Demande envoyée avec succès',
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
            'Votre demande de consultation a bien été envoyée. Un praticien vous contactera bientôt.',
            style: TextStyle(
              fontFamily: policePoppins,
              fontSize: 15,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Fermer le message de confirmation
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
    );
  }
}
