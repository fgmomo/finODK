import 'package:flutter/material.dart';
import 'package:meditra/views/home/appbottombar.dart';
import 'package:meditra/views/home/consultation.dart';
import 'package:meditra/views/home/plante.dart';
import 'package:meditra/views/home/remede.dart';
import 'package:meditra/views/home/visiteur_home.dart';
import 'package:meditra/views/home/visiteur_profil.dart';

class AccueilVisitorHomeScreen extends StatefulWidget {
  @override
  _AccueilVisitorHomeScreenState createState() =>
      _AccueilVisitorHomeScreenState();
}

class _AccueilVisitorHomeScreenState extends State<AccueilVisitorHomeScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
     duration: const Duration(milliseconds: 400),
        child: _getCurrentPage(),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.jumpToPage(_currentIndex);
        },
      ),
    );
  }

  Widget _getCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return VisitorHomeScreen(key: ValueKey(0));
      case 1:
        return PlanteScreen(key: ValueKey(1));
      case 2:
        return RemedeScreen(key: ValueKey(2));
      case 3:
        return VisitorProfilScreen(key: ValueKey(3));
      case 4: 
        return VisiteurConsultationScreen(key: ValueKey(0));
      default:
        return VisitorHomeScreen(key: ValueKey(0));
    }
  }
}
