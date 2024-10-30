import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';
import 'package:meditra/sevices/praticien_sevices.dart'; // Le service de récupération des praticiens

class PraticienPage extends StatefulWidget {
  const PraticienPage({super.key});

  @override
  State<PraticienPage> createState() => _PraticienPageState();
}

class _PraticienPageState extends State<PraticienPage> {
  final PraticienService _praticienService = PraticienService();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 245, 245, 245),
        title: Row(
          children: [
            Text(
              'Liste des Praticiens',
              style: TextStyle(fontFamily: policePoppins, color: Colors.black),
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
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _praticienService.recupererTousLesPraticiens(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final praticiens = snapshot.data!.where((praticien) {
              final fullName =
                  (praticien['firstName'] + ' ' + praticien['lastName'])
                      .toLowerCase();
              final email = praticien['email'].toLowerCase();

              return fullName.contains(searchQuery) ||
                  email.contains(searchQuery);
            }).toList();

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
                      1: FlexColumnWidth(2),
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
                          // _buildTableHeader('Adresse'),
                          _buildTableHeader('Status'),
                          _buildTableHeader('Status compte'),
                          _buildTableHeader('Actions'),
                        ],
                      ),
                      ...praticiens.map((praticien) {
                        return TableRow(
                          decoration: BoxDecoration(
                            color: praticiens.indexOf(praticien).isEven
                                ? Colors.white
                                : Colors.grey[100],
                          ),
                          children: [
                            _buildTableCell(praticien['firstName'] +
                                ' ' +
                                praticien['lastName']),
                            // _buildTableCell(praticien['address']),
                            // _buildTableCell(praticien['professionalNumber']),
                            _buildTableCell(praticien['status']),
                            _buildStatusBadge(praticien['isActive']),
                            _buildTableCellWithActions(praticien),
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

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      height: 40, // Ajustez la hauteur si nécessaire
      alignment: Alignment.center, // Centre le badge
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? Colors.green : Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          isActive ? "Actif" : "Inactif",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: policeLato,
          ),
        ),
      ),
    );
  }

  Widget _buildTableCellWithActions(Map<String, dynamic> praticien) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround, // Espacement uniforme
      children: [
        _buildActionIcon(
          icon: Icons.remove_red_eye,
          color: couleurPrincipale,
          label: 'Voir',
          onTap: () => _showDetailModal(praticien),
        ),
        if (praticien['status'] != 'approuvé' && praticien['status'] != 'rejeté') ...[
          _buildActionIcon(
            icon: Icons.check_circle,
            color: Colors.green,
            label: 'Approuver',
            onTap: () => _approvePraticien(praticien['reference']),
          ),
          _buildActionIcon(
            icon: Icons.cancel,
            color: Colors.red,
            label: 'Rejeter',
            onTap: () => _rejectPraticien(praticien['reference']),
          ),
        ] else if (praticien['status'] == 'approuvé') ...[
          _buildStatusBadgeLabel('Approuvé', Colors.green),
        ] else if (praticien['status'] == 'rejeté') ...[
          _buildStatusBadgeLabel('Rejeté', const Color.fromARGB(255, 255, 94, 94)),
        ],
        _buildActionIcon(
          icon: praticien['isActive'] ? Icons.block : Icons.check,
          color: praticien['isActive'] ? Colors.red : Colors.green,
          label: praticien['isActive'] ? 'Désactiver' : 'Activer',
          onTap: () {
            praticien['isActive']
                ? _desactiverPraticien(praticien['reference'])
                : _activerPraticien(praticien['reference']);
          },
        ),
      ],
    ),
  );
}

Widget _buildActionIcon({required IconData icon, required Color color, required String label, required Function() onTap}) {
  return Column(
    children: [
      IconButton(
        icon: Icon(icon, color: color),
        onPressed: onTap,
      ),
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
    ],
  );
}

Widget _buildStatusBadgeLabel(String text, Color color) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontFamily: policePoppins,
        color: Colors.white,
      ),
    ),
  );
}

  void _showDetailModal(Map<String, dynamic> praticien) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Détails du praticien',
              style: TextStyle(fontFamily: policePoppins)),
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
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: praticien['photoUrl'] != null &&
                              praticien['photoUrl'].isNotEmpty
                          ? NetworkImage(praticien['photoUrl'])
                          : null,
                      child: praticien['photoUrl'] == null ||
                              praticien['photoUrl'].isEmpty
                          ? Icon(Icons.person, size: 50)
                          : null,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                            'Status', praticien['status'] ?? 'Non spécifié'),
                        _buildDetailRow('Nom',
                            '${praticien['firstName'] ?? ''} ${praticien['lastName'] ?? ''}'),
                        _buildDetailRow(
                            'Email', praticien['email'] ?? 'Non spécifié'),
                        _buildDetailRow(
                            'Adresse', praticien['address'] ?? 'Non spécifié'),
                        _buildDetailRow('Numéro professionnel',
                            praticien['professionalNumber'] ?? 'Non spécifié'),
                        _buildDetailRow('Motivation',
                            praticien['justification'] ?? 'Non spécifié'),
                        SizedBox(height: 20),
                        Text(
                          'Pièce justificatif',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                            fontFamily: policePoppins,
                          ),
                        ),
                        _buildImage(praticien['justificatifUrl'] ?? ''),
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label :',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black,
              fontFamily: policePoppins,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String url) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: url.isNotEmpty
          ? Image.network(
              url,
              fit: BoxFit.cover,
            )
          : Center(child: Text('Pas de document disponible')),
    );
  }

  void _approvePraticien(String reference) {
    _praticienService.approuverPraticien(reference).then((_) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Praticien approuvé avec succès',
          style: TextStyle(fontFamily: policePoppins),
        ),
        backgroundColor: Colors.green,
      ));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Erreur lors de l\'approbation',
          style: TextStyle(fontFamily: policePoppins),
        ),
        backgroundColor: Colors.red,
      ));
    });
  }

  void _rejectPraticien(String reference) {
    _praticienService.rejeterPraticien(reference).then((_) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Praticien rejeté avec succès',
          style: TextStyle(fontFamily: policePoppins),
        ),
        backgroundColor: Colors.red,
      ));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Erreur lors du rejet',
          style: TextStyle(fontFamily: policePoppins),
        ),
        backgroundColor: Colors.red,
      ));
    });
  }

  void _desactiverPraticien(String praticienId) async {
    try {
      await _praticienService.desactiverPraticien(praticienId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Utilisateur désactivé avec succès'),
      ));

      // Actualiser la liste après la désactivation
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur lors de la désactivation'),
      ));
    }
  }

  void _activerPraticien(String praticienId) async {
    try {
      await _praticienService.activerPraticien(praticienId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Utilisateur activé avec succès'),
      ));

      // Actualiser la liste après la désactivation
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur lors de l\'activation'),
      ));
    }
  }
}
