// lib/screens/visitor_home_screen.dart

import 'package:flutter/material.dart';
import 'package:meditra/views/home/plante.dart';
import 'package:meditra/views/home/remede.dart';
import 'package:meditra/views/home_praticien/appbottombar.dart';
import 'package:meditra/views/home_praticien/praticien_consultation.dart';
import 'package:meditra/views/home_praticien/praticien_home.dart';


class AccueilPraticienHomeScreen extends StatefulWidget {
  @override
  _AccueilPraticienHomeScreenState createState() =>
      _AccueilPraticienHomeScreenState();
}

class _AccueilPraticienHomeScreenState extends State<AccueilPraticienHomeScreen> {
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
      body: PageView(
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        controller: _pageController,
        children: <Widget>[
          PraticienHomeScreen(),
          PlanteScreen(),
          RemedeScreen(),
          PraticienConsultationScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBarPraticien(
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
}
