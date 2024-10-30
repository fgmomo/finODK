import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';
import 'package:meditra/sevices/plante_service.dart';
import 'package:meditra/views/admin_home/pages/add_plante_modal.dart';
import 'package:meditra/views/admin_home/pages/edit_plante_modal.dart';

class PlantePage extends StatefulWidget {
  const PlantePage({Key? key}) : super(key: key);

  @override
  State<PlantePage> createState() => _PlantePageState();
}

class _PlantePageState extends State<PlantePage> {
  late Future<List<Plante>> _futurePlantes;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _futurePlantes = PlanteService().fetchPlantes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Row(
          children: [
            Text('Liste des Plantes',
                style: TextStyle(fontFamily: policePoppins)),
            SizedBox(width: 10),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return PlanteModal();
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


      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          FutureBuilder<List<Plante>>(
            future: _futurePlantes,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                    child: Text('Erreur: ${snapshot.error}',
                        style: TextStyle(fontFamily: policePoppins)));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                    child: Text('Aucune plante trouvée',
                        style: TextStyle(fontFamily: policePoppins)));
              } else {
                return Expanded(
                  child: Container(
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width * 0.85,
                          ),
                          child: DataTable(
                            columnSpacing: 50,
                            columns: const [
                              DataColumn(
                                  label: Text('Nom',
                                      style: TextStyle(
                                          fontFamily: policePoppins))),
                              DataColumn(
                                  label: Text('Nom Local',
                                      style: TextStyle(
                                          fontFamily: policePoppins))),
                              DataColumn(
                                  label: Text('Image',
                                      style: TextStyle(
                                          fontFamily: policePoppins))),
                              DataColumn(
                                  label: Text('Actions',
                                      style: TextStyle(
                                          fontFamily: policePoppins))),
                            ],
                            rows: List<DataRow>.generate(
                              snapshot.data!
                                  .where((plante) =>
                                      plante.nom
                                          .toLowerCase()
                                          .contains(searchQuery) ||
                                      plante.nomLocal
                                          .toLowerCase()
                                          .contains(searchQuery) ||
                                      plante.description
                                          .toLowerCase()
                                          .contains(searchQuery))
                                  .length,
                              (index) {
                                final plante = snapshot.data!
                                    .where((plante) =>
                                        plante.nom
                                            .toLowerCase()
                                            .contains(searchQuery) ||
                                        plante.nomLocal
                                            .toLowerCase()
                                            .contains(searchQuery) ||
                                        plante.description
                                            .toLowerCase()
                                            .contains(searchQuery))
                                    .elementAt(index);
                                return DataRow(
                                  color:
                                      MaterialStateProperty.resolveWith<Color?>(
                                          (Set<MaterialState> states) {
                                    // Alternance des couleurs des lignes
                                    return index % 2 == 0
                                        ? Colors.grey[100]
                                        : Colors.white; // Couleurs alternées
                                  }),
                                  cells: [
                                    DataCell(Text(plante.nom,
                                        style: TextStyle(
                                            fontFamily: policePoppins))),
                                    DataCell(Text(plante.nomLocal,
                                        style: TextStyle(
                                            fontFamily: policePoppins))),
                                    DataCell(
                                      Container(
                                        width: 50,
                                        height: 50,
                                        alignment: Alignment.center,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: CircleAvatar(
                                            radius: 25,
                                            backgroundImage: plante.imageUrl !=
                                                        null &&
                                                    plante.imageUrl.isNotEmpty
                                                ? NetworkImage(
                                                    plante.imageUrl,
                                                  ) // Affiche l'image de profil à partir de l'URL
                                                : AssetImage(
                                                    'assets/prof.jpg'), // Image par défaut
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.visibility,
                                                color: Colors.orange),
                                            onPressed: () {
                                              _showPlanteDetails(
                                                  context, plante);
                                            },
                                            tooltip: 'Voir les détails',
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.edit,
                                                color: Colors.blue),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return EditPlanteModal(
                                                      planteRef:
                                                          plante.reference!);
                                                },
                                              );
                                            },
                                            tooltip: 'Modifier',
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () async {
                                              final shouldDelete =
                                                  await showDialog<bool>(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: Text('Confirmation'),
                                                    content: Text(
                                                        'Voulez-vous vraiment supprimer cette plante ?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop(false);
                                                        },
                                                        child: Text('Annuler'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop(true);
                                                        },
                                                        child: Text('Supprimer',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .red)),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );

                                              if (shouldDelete == true) {
                                                try {
                                                  await PlanteService()
                                                      .deletePlante(
                                                          plante.reference!);
                                                  setState(() {
                                                    _futurePlantes =
                                                        PlanteService()
                                                            .fetchPlantes();
                                                  });
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(
                                                            'Plante supprimée avec succès')),
                                                  );
                                                } catch (error) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(
                                                            'Erreur lors de la suppression')),
                                                  );
                                                }
                                              }
                                            },
                                            tooltip: 'Supprimer',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showPlanteDetails(BuildContext context, Plante plante) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(plante.nom, style: TextStyle(fontFamily: policePoppins)),
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
                      plante.imageUrl,
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
                          'Nom Local', // Titre en gras
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: policePoppins,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          plante.nomLocal, // Contenu en dessous
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
                          plante.description, // Contenu en dessous
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontFamily: policePoppins,
                          ),
                        ),
                        SizedBox(height: 10),

                        // Bienfaits
                        Text(
                          'Bienfaits', // Titre en gras
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: policePoppins,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          plante.bienfaits, // Contenu en dessous
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
}
