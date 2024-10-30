import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';
import 'package:meditra/sevices/admin_service.dart';
import 'package:meditra/sevices/user_service.dart';
import 'package:meditra/views/admin_home/pages/add_admin_modal.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final AdminService _adminService = AdminService();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 245, 245, 245),
        title: Row(
          children: [
            Text('Liste des Administrateurs',
                style: TextStyle(fontFamily: policePoppins)),
            SizedBox(width: 10),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AddAdminModal(
                      onAdminAdded: () {
                        // Mettre à jour l'état lorsque l'administrateur est ajouté
                        setState(() {
                          // Logique de mise à jour de l'interface utilisateur après l'ajout d'un admin
                        });
                      },
                    );
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
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _adminService.recupererTousLesAdmins(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final admins = snapshot.data!.where((admin) {
              final fullName =
                  (admin['firstName'] + ' ' + admin['lastName']).toLowerCase();
              final email = admin['email'].toLowerCase();

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
                          _buildTableHeader('Prénom'),
                          _buildTableHeader('email'),
                          _buildTableHeader('image'),
                          _buildTableHeader('Status compte'),
                          _buildTableHeader('Actions'),
                        ],
                      ),
                      ...admins.map((admin) {
                        return TableRow(
                          decoration: BoxDecoration(
                            color: admins.indexOf(admin).isEven
                                ? Colors.white
                                : Colors.grey[100],
                          ),
                          children: [
                            _buildTableCell(admin['firstName']),
                            _buildTableCell(admin['lastName']),
                            _buildTableCell(admin['email']),
                            _buildTableImageCell(
                              admin['profileImageUrl'] != null &&
                                      admin['profileImageUrl'].isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        admin['profileImageUrl'],
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(Icons.broken_image,
                                              size: 50);
                                        },
                                      ),
                                    )
                                  : ClipOval(
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        color: Colors.grey[300],
                                        child: Icon(Icons.person, size: 50),
                                      ),
                                    ),
                            ),
                            _buildStatusBadge(admin[
                                'isActive']), // Ajout de la cellule 'Status compte'
                            _buildTableCellWithActions(
                                admin), // Ajout de la cellule 'Actions'
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

  Widget _buildTableCell(String text, {bool isActive = true}) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        isActive ? text : '$text (désactivé)',
        style: TextStyle(
          fontSize: 14,
          fontFamily: policePoppins,
          color: isActive ? Colors.black : Colors.grey,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCellWithActions(Map<String, dynamic> admin) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              admin['isActive']
                  ? Icons.block
                  : Icons.check, // Changez ici l'icône
              color: admin['isActive']
                  ? Colors.red
                  : Colors.green, // Changez ici la couleur
            ),
            onPressed: () {
              if (admin['isActive']) {
                _desactiverAdmin(admin['reference']);
              } else {
                // Ajoutez ici la logique pour activer le admin
                _activerAdmin(admin['reference']);
              }
            },
          ),
        ],
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

  Widget _buildTableImageCell(Widget imageWidget) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Center(child: imageWidget),
    );
  }

  void _desactiverAdmin(String adminId) async {
    try {
      await _adminService.desactiverAdmin(adminId);
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

  void _activerAdmin(String adminId) async {
    try {
      await _adminService.activerAdmin(adminId);
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
