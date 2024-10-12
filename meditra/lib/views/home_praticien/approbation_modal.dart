import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String primaryButtonText;
  final String secondaryButtonText;
  final VoidCallback onPrimaryButtonPressed;
  final VoidCallback? onSecondaryButtonPressed;
  final Color backgroundColor;
  final IconData icon;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.primaryButtonText,
    required this.onPrimaryButtonPressed,
    this.secondaryButtonText = 'Fermer', // Par défaut le texte du bouton secondaire est "Fermer"
    this.onSecondaryButtonPressed,
    this.backgroundColor = Colors.white,
    this.icon = Icons.check,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: icon == Icons.check ? Colors.green : Colors.red,
            ),
            padding: EdgeInsets.all(16),
            child: Icon(
              icon,
              size: 40,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'Poppins',
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
          onPressed: onPrimaryButtonPressed, // Action du bouton principal (ouvrir la discussion)
          child: Text(
            primaryButtonText,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.blue,
              fontSize: 16,
            ),
          ),
        ),
        if (onSecondaryButtonPressed != null)
          TextButton(
            onPressed: onSecondaryButtonPressed ?? () {
              Navigator.of(context).pop(); // Fermer par défaut si aucune action définie
            },
            child: Text(
              secondaryButtonText,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
          ),
      ],
    );
  }
}
