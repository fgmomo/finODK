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
          label: '', // Label vide
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.grass),
          label: '', // Label vide
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: '', // Label vide
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.article),
          label: '', // Label vide
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '', // Label vide
        ),
      ],
      selectedItemColor: couleurPrincipale,
      unselectedItemColor: const Color.fromARGB(255, 187, 216, 187),
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false, // Ne pas afficher les labels sélectionnés
      showUnselectedLabels:
          false, // Ne pas afficher les labels non sélectionnés
      iconSize: 30, // Ajuste la taille des icônes
    );
  }
}
