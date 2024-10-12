import 'package:flutter/material.dart';
import 'package:meditra/views/admin_home/pages/admin_page.dart';
import 'package:meditra/views/admin_home/pages/maladie.dart';
import 'package:meditra/views/admin_home/pages/plante.dart';
import 'package:meditra/views/admin_home/pages/remede.dart';
import 'package:meditra/views/admin_home/pages/remede_maladie.dart';
import '../components/sidebar.dart';
import '../components/header.dart';
import '../pages/home_page.dart';
import '../pages/user_page.dart';

class MainLayout extends StatefulWidget {
  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedPageIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    UserPage(),
    AdminPage(),
    PlantePage(),
    RemedePage(),
    MaladiePage(),
    RemedeMaladiePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Ajout du Drawer pour petits écrans
      drawer: (MediaQuery.of(context).size.width <= 800)
          ? Drawer(
              child: Sidebar(onItemSelected: _onItemTapped), // Sidebar dans un Drawer
            )
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return Row(
              children: [
                Sidebar(onItemSelected: _onItemTapped), // Sidebar visible
                Expanded(
                  child: Column(
                    children: [
                      Header(),
                      Expanded(child: _pages[_selectedPageIndex]),
                    ],
                  ),
                ),
              ],
            );
          } else {
            // Pour petits écrans, on cache la Sidebar et on utilise le Drawer
            return Column(
              children: [
                Header(), // Header avec menu hamburger
                Expanded(child: _pages[_selectedPageIndex]),
              ],
            );
          }
        },
      ),
    );
  }
}
