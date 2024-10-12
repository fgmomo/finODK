import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';
import 'package:meditra/views/home/consultation_approuve.dart';
import 'package:meditra/views/home/consultation_attente.dart';
import 'package:meditra/views/home/consultation_rejet.dart';


class VisiteurConsultationAllScreen extends StatefulWidget {
  const VisiteurConsultationAllScreen({super.key});

  @override
  State<VisiteurConsultationAllScreen> createState() =>
      _VisiteurConsultationAllScreenState();
}

class _VisiteurConsultationAllScreenState
    extends State<VisiteurConsultationAllScreen> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Two tabs: "En attente" and "Approuvé"
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mes Consultations',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: policeLato,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
      
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Divider(
              color: Color.fromARGB(255, 233, 233, 233),
              height: 0.1,
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            // TabBar for "En attente" "Approuvée" "Rejetée"
            const TabBar(
              labelColor: Colors.black,
              indicatorColor: couleurPrincipale,
              labelStyle: TextStyle(fontFamily: policePoppins),
              tabs: [
                Tab(text: "En attente",),
                Tab(text: "Approuvée"),
                Tab(text: "Rejetée"),
              ],
            ),
            // TabBarView for displaying the content of the selected tab
            Expanded(
              child: TabBarView(
                children: [
                  // First tab: "En attente" -> Display the consultation screen
                  const VisiteurAllAttenteConsultationScreen(),

                  // Second tab: "Approuvée" -> Placeholder text (can be replaced with actual content)
                   const VisiteurAllApprouveConsultationScreen(),

                    // Second tab: "Rejetée" -> Placeholder text (can be replaced with actual content)
                   const VisiteurAllRejeteConsultationScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
