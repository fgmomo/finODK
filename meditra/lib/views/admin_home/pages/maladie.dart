import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditra/sevices/maladie_service.dart';
import 'package:meditra/views/admin_home/pages/add_maladie_modal.dart';
import 'package:meditra/views/admin_home/pages/edit_maladie_modal.dart';

class MaladiePage extends StatefulWidget {
  const MaladiePage({super.key});

  @override
  State<MaladiePage> createState() => _MaladiePageState();
}

class _MaladiePageState extends State<MaladiePage> {
  final MaladieService _maladieservice = MaladieService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 245, 245, 245),
        title: Row(
          children: [
            Text('Liste des Maladies',
                style: TextStyle(fontFamily: policePoppins)),
            SizedBox(width: 10),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return MaladieAddModal(maladieService: _maladieservice);
                  },
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: couleurPrincipale,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              child: Text(
                'Ajouter',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: policePoppins,
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _maladieservice.getMaladies(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final maladies = snapshot.data!.docs;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(3),
                      2: FlexColumnWidth(1), // Pour les actions
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        children: [
                          _buildTableHeader('Nom'),
                          _buildTableHeader('Description'),
                          _buildTableHeader(
                              'Actions'), // Ajout de l'en-tête pour les actions
                        ],
                      ),
                      ...maladies.map((maladie) {
                        return TableRow(
                          decoration: BoxDecoration(
                            color: maladies.indexOf(maladie).isEven
                                ? Colors.white
                                : Colors.grey[100],
                          ),
                          children: [
                            _buildTableCell(maladie['nom']),
                            _buildTableCell(maladie['description']),
                            _buildTableCellWithActions(
                                maladie), // Ajouter le champ d'action
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          fontFamily: policePoppins,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontFamily: policePoppins,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCellWithActions(QueryDocumentSnapshot maladie) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return EditMaladieModal(
                    maladieRef: maladie.reference, // Utiliser la référence de la maladie
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              // Afficher le modal de confirmation
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Confirmer la suppression'),
                    content: Text(
                        'Êtes-vous sûr de vouloir supprimer cette maladie ?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          // Fermer le modal sans supprimer
                          Navigator.of(context).pop();
                        },
                        child: Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Appeler la fonction de suppression
                          _maladieservice.deleteMaladie(maladie.id);

                          // Fermer le modal après suppression
                          Navigator.of(context).pop();

                          // Afficher un message de succès (facultatif)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Maladie supprimée avec succès!')),
                          );
                        },
                        child: Text('Supprimer',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
