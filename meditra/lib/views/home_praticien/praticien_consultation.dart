import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';
import 'package:meditra/views/home_praticien/praticien_all_consultation.dart';
import 'package:meditra/views/home_praticien/praticien_all_consultation_historique%20.dart';
import 'package:meditra/views/home_praticien/praticien_crenaux.dart';


class PraticienConsultationScreen extends StatefulWidget {
  const PraticienConsultationScreen({super.key});

  @override
  State<PraticienConsultationScreen> createState() =>
      _PraticienConsultationScreenState();
}

class _PraticienConsultationScreenState
    extends State<PraticienConsultationScreen> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: "En attente" and "Historique"
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Consultations',
                style: TextStyle(
                  color: Colors.black,
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
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PraticienCrenauxScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.remove_red_eye, color: Colors.white),
                    label: const Text(
                      'Mes créneaux',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: couleurPrincipale,
                      padding: const EdgeInsets.symmetric(
                          vertical: 13, horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.grey,
              thickness: 0.5,
              indent: 16,
              endIndent: 18,
            ),
            // TabBar for "En attente" and "Historique"
            const TabBar(
              labelColor: Colors.black,
              indicatorColor: couleurPrincipale,
              tabs: [
                Tab(text: "En attente"),
                Tab(text: "Historique"),
              ],
            ),
            // TabBarView for displaying the content of the selected tab
            Expanded(
              child: TabBarView(
                children: [
                  // First tab: "En attente" -> Display the consultation screen
                  const PraticienAllConsultationScreen(),

                  // Second tab: "Historique" -> Placeholder text (can be replaced with actual content)
                  const PraticienAllConsultationHistoriqueScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
