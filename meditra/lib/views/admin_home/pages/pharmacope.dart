  import 'package:flutter/material.dart';
  import 'package:meditra/config/config.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:meditra/sevices/centres_pharma_service.dart';
  import 'package:meditra/views/admin_home/pages/add_centre_modal.dart';
  import 'package:meditra/views/admin_home/pages/edit_centre_modal%20copy.dart';
  import 'package:meditra/views/admin_home/pages/edit_maladie_modal.dart';

  class PharmacopePage extends StatefulWidget {
    const PharmacopePage({super.key});

    @override
    State<PharmacopePage> createState() => _PharmacopePageState();
  }

  class _PharmacopePageState extends State<PharmacopePage> {
    final CentreService _centreservice = CentreService();

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 245, 245, 245),
          title: Row(
            children: [
              Text('Liste des centres de pharmacopées',
                  style: TextStyle(fontFamily: policePoppins)),
              SizedBox(width: 10),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CentreAddModal();
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
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _centreservice.recupererCentresPharmacopee(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final centres = snapshot.data!;

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
                        3: FlexColumnWidth(2),
                        4: FlexColumnWidth(2),
                        5: FlexColumnWidth(1),
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
                            _buildTableHeader('Adresse'),
                            _buildTableHeader('Téléphone'),
                            _buildTableHeader('Actions'),
                          ],
                        ),
                        ...centres.map((centre) {
                          return TableRow(
                            decoration: BoxDecoration(
                              color: centres.indexOf(centre).isEven
                                  ? Colors.white
                                  : Colors.grey[100],
                            ),
                            children: [
                              _buildTableCell(centre['nom']),
                              _buildTableCell(centre['description']),
                              _buildTableCell(centre['adresse']),
                              _buildTableCell(centre['telephone']),
                              _buildTableCellWithActions(centre),
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

    Widget _buildTableCellWithActions(Map<String, dynamic> centre) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.remove_red_eye, color: Colors.green),
              onPressed: () {
                _showDetailModal(centre); // Afficher les détails dans un modal
              },
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return EditCentreModal(
                      centreRef: centre['reference'],
                    );
                  },
                );
              },
            ),
          IconButton(
    icon: Icon(Icons.delete, color: Colors.red),
    onPressed: () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text(
              'Confirmer la suppression',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            content: Text(
              'Êtes-vous sûr de vouloir supprimer ce centre ?',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer le modal de confirmation
                },
                child: Text(
                  'Annuler',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              ),
              TextButton(
                onPressed: () async {
                  // Appel de la méthode de suppression dans le service avec la référence du centre
                    await _centreservice.deleteCentre(centre['reference']);

                  // Fermer le modal après la suppression
                  Navigator.of(context).pop();

                  // Afficher un message de succès après la suppression
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Centre supprimé avec succès!',
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                     // Rafraîchir la page en appelant setState
    setState(() {});
                },
                child: Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red, fontFamily: 'Poppins'),
                ),
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

    // Fonction pour afficher le modal avec les détails
    void _showDetailModal(Map<String, dynamic> centre) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
           return AlertDialog(
          title: Text(centre['nom'], style: TextStyle(fontFamily: policePoppins)),
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
                      centre['image'] ?? '',
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
                        // Nom Local
                        Text(
                          'Nom du centre', // Titre en gras
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: policePoppins,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                         centre['nom'] ??'Non disponible', // Contenu en dessous
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontFamily: policePoppins,
                          ),
                        ),
                        SizedBox(height: 10),

                        // Description
                        Text(
                          'Adresse', // Titre en gras
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: policePoppins,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          centre['adresse'] ??'Non disponible', // Contenu en dessous
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontFamily: policePoppins,
                          ),
                        ),
                        SizedBox(height: 10),

          
                        Text(
                          'Téléphone', // Titre en gras
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: policePoppins,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          centre['telephone'] ?? 'Non disponible', // Contenu en dessous
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontFamily: policePoppins,
                          ),
                        ),

                         Text(
                          'Email', // Titre en gras
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: policePoppins,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          centre['email'] ??'Non disponible',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontFamily: policePoppins,
                          ),
                        ),

                          Text(
                          'Site Web', // Titre en gras
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: policePoppins,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          centre['siteWeb'] ?? 'Non disponible',
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
          // return AlertDialog(
          //   title: Text('Détails du centre'),
          //   content: Column(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Text('Nom: ${centre['nom']}'),
          //       Text('Adresse: ${centre['adresse']}'),
          //       Text('Téléphone: ${centre['telephone']}'),
          //       Text('Email: ${centre['email'] ?? 'Non disponible'}'),
          //       Text('Site Web: ${centre['siteWeb'] ?? 'Non disponible'}'),
          //       Image.network(
          //         centre['image'] ?? '',
          //         height: 100,
          //         errorBuilder: (context, error, stackTrace) => Text('Image non disponible'),
          //       ),
          //     ],
          //   ),
          //   actions: [
          //     TextButton(
          //       onPressed: () {
          //         Navigator.of(context).pop();
          //       },
          //       child: Text('Fermer'),
          //     ),
          //   ],
          // );
        },
      );
    }
  }
