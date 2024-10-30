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
  String searchQuery = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Row(
          children: [
            Text('Liste des Rémèdes',
                style: TextStyle(fontFamily: policePoppins)),
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
            const Spacer(),
            SizedBox(
              width: 200,
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Rechercher...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                ),
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _remedeService.getRemedes(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            // Filtrage des remèdes en fonction de la recherche
            final remedes = snapshot.data!.docs.where((remede) {
              final nom = remede['nom'].toString().toLowerCase();
              final description =
                  remede['description'].toString().toLowerCase();
              final utilisation =
                  remede['utilisation'].toString().toLowerCase();

              return nom.contains(searchQuery) ||
                  description.contains(searchQuery) ||
                  utilisation.contains(searchQuery);
            }).toList();

            // Si aucune donnée ne correspond à la recherche
            if (remedes.isEmpty) {
              return Center(
                child: Text(
                  'Aucun remède trouvé.',
                  style: TextStyle(fontSize: 18, fontFamily: policePoppins),
                ),
              );
            }

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
                            color: remedes.indexOf(remede).isEven
                                ? Colors.white
                                : Colors.grey[100],
                          ),
                          children: [
                            _buildTableCell(remede['nom']),
                            _buildTableCell(
                                _getShortDescription(remede['description'])),
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
    return description.length > 50
        ? description.substring(0, 50) + '...'
        : description;
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
      padding: const EdgeInsets.all(3),
      child: CircleAvatar(
        radius: 25,
        backgroundImage: imageUrl != null && imageUrl.isNotEmpty
            ? NetworkImage(
                imageUrl) // Affiche l'image de profil à partir de l'URL
            : AssetImage('assets/prof.jpg'), // Image par défaut
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
                      remedeRef:
                          remede.reference, // Utiliser la référence du remède
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
                      content: Text(
                          'Êtes-vous sûr de vouloir supprimer ce remède ?'),
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
                              SnackBar(
                                  content:
                                      Text('Remède supprimé avec succès!')),
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
          title:
              Text(remede['nom'], style: TextStyle(fontFamily: policePoppins)),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 300,
              maxHeight: 400,
              minWidth: 300,
              maxWidth: 500,
            ),
            child: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      remede['image'],
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.broken_image, size: 150);
                      },
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nom du rémède', // Titre en gras
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: policePoppins,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          remede['nom'], // Contenu en dessous
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontFamily: policePoppins,
                          ),
                        ),
                        SizedBox(height: 10),

                        // Description
                        Text(
                          'Description', // Titre en gras
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: policePoppins,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          remede['description'], // Contenu en dessous
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontFamily: policePoppins,
                          ),
                        ),
                        SizedBox(height: 10),

                        // Utilisation
                        Text(
                          'Utilisation', // Titre en gras
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: policePoppins,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          remede['utilisation'], // Contenu en dessous
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontFamily: policePoppins,
                          ),
                        ),
                        SizedBox(height: 10),

                        // Précaution
                        Text(
                          'Précaution', // Titre en gras
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: policePoppins,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          remede['precaution'], // Contenu en dessous
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontFamily: policePoppins,
                          ),
                        ),
                        SizedBox(height: 10),

                        // Dosage
                        Text(
                          'Dosage', // Titre en gras
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: policePoppins,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          remede['dosage'], // Contenu en dessous
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontFamily: policePoppins,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fermer',
                  style: TextStyle(
                      color: Colors.green[700], fontFamily: policePoppins)),
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
            style: TextStyle(
                fontWeight: FontWeight.bold, fontFamily: policePoppins),
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
