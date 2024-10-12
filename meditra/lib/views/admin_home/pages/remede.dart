import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';
import 'package:meditra/sevices/remede_service.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditra/views/admin_home/pages/add_remede_modal.dart';
import 'package:meditra/views/admin_home/pages/edit_remede_modal.dart';

class RemedePage extends StatefulWidget {
  const RemedePage({super.key});

  @override
  State<RemedePage> createState() => _RemedePageState();
}

class _RemedePageState extends State<RemedePage> {
  final RemedeService _remedeService = RemedeService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 245, 245, 245),
        title: Row(
          children: [
            Text('Tableau des Rémèdes', style: TextStyle(fontFamily: policePoppins)),
            SizedBox(width: 10),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return RemedeAddModal();
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
          stream: _remedeService.getRemedes(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final remedes = snapshot.data!.docs;

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
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(2), // Pour l'image
                      4: FlexColumnWidth(1), // Pour les actions (icône œil)
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
                          _buildTableHeader('Description Résumée'),
                          _buildTableHeader('Utilisation'),
                          _buildTableHeader('Image'),
                          _buildTableHeader('Actions'),
                        ],
                      ),
                      ...remedes.map((remede) {
                        return TableRow(
                          decoration: BoxDecoration(
                            color: remedes.indexOf(remede).isEven ? Colors.white : Colors.grey[100],
                          ),
                          children: [
                            _buildTableCell(remede['nom']),
                            _buildTableCell(_getShortDescription(remede['description'])),
                            _buildTableCell(remede['utilisation']),
                            _buildImageCell(remede['image']),
                            _buildActionIcons(remede),
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

  String _getShortDescription(String description) {
    return description.length > 50 ? description.substring(0, 50) + '...' : description;
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

  // Nouvelle fonction pour afficher l'image dans une cellule du tableau
  Widget _buildImageCell(String imageUrl) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Image.network(
        imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.image_not_supported, color: Colors.grey);
        },
      ),
    );
  }

Widget _buildActionIcons(QueryDocumentSnapshot remede) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: IconButton(
            icon: Icon(Icons.remove_red_eye, color: Colors.green),
            onPressed: () {
              _showRemedeDetails(remede);
            },
          ),
        ),
        Flexible(
          child: IconButton(
            icon: Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditRemedeModal(
          remedeRef: remede.reference, // Utiliser la référence du remède
        );
      },
    );
            },
          ),
        ),
     Flexible(
  child: IconButton(
    icon: Icon(Icons.delete, color: Colors.red),
    onPressed: () {
      // Afficher le modal de confirmation
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmer la suppression'),
            content: Text('Êtes-vous sûr de vouloir supprimer ce remède ?'),
            actions: [
              TextButton(
                onPressed: () {
                  // Ferme le modal sans supprimer
                  Navigator.of(context).pop();
                },
                child: Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  // Appeler la fonction de suppression
                  _remedeService.deleteRemede(remede.id);

                  // Ferme le modal après suppression
                  Navigator.of(context).pop();

                  // Afficher un message de succès (facultatif)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Remède supprimé avec succès!')),
                  );
                },
                child: Text('Supprimer', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );
    },
  ),
),
      ],
    ),
  );
}

  void _showRemedeDetails(QueryDocumentSnapshot remede) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(remede['nom']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                remede['image'],
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.image_not_supported, size: 100, color: Colors.grey);
                },
              ),
              SizedBox(height: 10),
              _buildDetailRow('Description', remede['description']),
              _buildDetailRow('Utilisation', remede['utilisation']),
              _buildDetailRow('Précaution', remede['precaution']),
              _buildDetailRow('Dosage', remede['dosage']),
            ],
          ),  
          actions: [
            TextButton(
              child: Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label : ',
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: policePoppins),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontFamily: policePoppins),
            ),
          ),
        ],
      ),
    );
  }
}
