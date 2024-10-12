import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';

class Sidebar extends StatefulWidget {
  final Function(int) onItemSelected;

  Sidebar({required this.onItemSelected});

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  int _hoveredIndex = -1; // Pour savoir quel élément est survolé
  int _selectedIndex = -1; // Pour savoir quel élément est sélectionné

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white, // Le fond du sidebar est blanc
      child: ListView(
        children: [
          DrawerHeader(
            child: Text(
              'Backoffice Menu',
              style: TextStyle(
                color: couleurPrincipale,
                fontSize: 24,
                fontFamily: policePoppins, // Utilisation de la police Poppins
              ),
            ),
          ),
          _buildListItem(
            index: 0,
            icon: Icons.home,
            text: 'Dashboard',
            onTap: () {
              setState(() {
                _selectedIndex = 0; // Met à jour l'index sélectionné
              });
              widget.onItemSelected(0);
            },
          ),
          _buildListItem(
            index: 1,
            icon: Icons.person,
            text: 'User',
            onTap: () {
              setState(() {
                _selectedIndex = 1; // Met à jour l'index sélectionné
              });
              widget.onItemSelected(1);
            },
          ),

           _buildListItem(
            index: 2,
            icon: Icons.person,
            text: 'Administrateur',
            onTap: () {
              setState(() {
                _selectedIndex = 2; // Met à jour l'index sélectionné
              });
              widget.onItemSelected(2);
            },
          ),

          _buildListItem(
            index: 3,
              icon: Icons.local_florist,
            text: 'Plantes',
            onTap: () {
              setState(() {
                _selectedIndex = 3; 
              });
              widget.onItemSelected(3);
            },
          ),
          
           _buildListItem(
            index: 4,
              icon: Icons.healing,
            text: 'Rémèdes',
            onTap: () {
              setState(() {
                _selectedIndex = 4; 
              });
              widget.onItemSelected(4);
            },
          ),
             _buildListItem(
            index: 5,
              icon: Icons.health_and_safety,
            text: 'Maladies',
            onTap: () {
              setState(() {
                _selectedIndex = 5; 
              });
              widget.onItemSelected(5);
            },
          ),

           _buildListItem(
            index: 6,
              icon: Icons.health_and_safety,
            text: 'Remedes-Maladies',
            onTap: () {
              setState(() {
                _selectedIndex = 6; 
              });
              widget.onItemSelected(6);
            },
          ),
          // Ajoutez d'autres éléments de menu ici
        ],
      ),
    );
  }

  // Widget pour un élément de la liste principale
  Widget _buildListItem({
    required int index,
    required IconData icon,
    required String text,
    required Function() onTap,
  }) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = -1),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: _hoveredIndex == index || _selectedIndex == index
              ? couleurSecondaire
              : Colors.transparent, // Appliquer couleurSecondaire au hover et à la sélection
          borderRadius: BorderRadius.circular(5), // borderRadius: 5
        ),
        child: ListTile(
          leading: Icon(icon, color: couleurPrincipale), // Couleur des icônes : couleurPrincipale
          title: Text(
            text,
            style: TextStyle(
              color: Colors.black, // Texte noir
              fontFamily: policePoppins, // Utilisation de la police Poppins
            ),
          ),
          onTap: onTap, // Action lors du clic
        ),
      ),
    );
  }

  // Widget pour un élément dans le sous-menu déroulant
  Widget _buildSubListItem({
    required IconData icon,
    required String text,
    required Function() onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: couleurPrincipale),
      title: Text(
        text,
        style: TextStyle(
          color: Colors.black,
          fontFamily: policePoppins,
        ),
      ),
      onTap: onTap,
    );
  }
}
