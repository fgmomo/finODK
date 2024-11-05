import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Accueil', // Label ajouté
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Consultation', // Label ajouté
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_pharmacy),
          label: 'Rémèdes', // Label ajouté
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.description),
          label: 'Articles', // Label ajouté
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil', // Label ajouté
        ),
      ],
      selectedItemColor: couleurPrincipale,
      unselectedItemColor: couleurSecondaire,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true, // Afficher les labels sélectionnés
      showUnselectedLabels: true, // Afficher les labels non sélectionnés
      iconSize: 26, // Ajuste la taille des icônes

      // Styles pour les labels
         // Styles pour les labels
      selectedLabelStyle: TextStyle(
        fontSize: 12, // Taille de la police pour les labels sélectionnés
        // fontWeight: FontWeight.bold, // Épaisseur de la police
        color: couleurPrincipale, // Couleur du label sélectionné
        fontFamily: policePoppins, // Remplace 'Roboto' par la police de ton choix
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 9, // Taille de la police pour les labels non sélectionnés
        // fontWeight: FontWeight.normal, // Épaisseur de la police
        color: couleurSecondaire, // Couleur du label non sélectionné
        fontFamily: policeLato, // Police de ton choix pour les labels non sélectionnés
      ),// Ajuste la taille des icônes
    );
  }
}
