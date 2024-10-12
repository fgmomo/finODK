import 'package:flutter/material.dart';
import 'package:meditra/sevices/remede_maladie_service.dart';

class RemedeMaladiePage extends StatefulWidget {
  const RemedeMaladiePage({super.key});

  @override
  State<RemedeMaladiePage> createState() => _RemedeMaladiePageState();
}

class _RemedeMaladiePageState extends State<RemedeMaladiePage> {
  final RemedeMaladieService _remedeMaladieService = RemedeMaladieService();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 245, 245, 245),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Remèdes par Maladie',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.black,
                fontSize: 20,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: SizedBox(
                width: 250,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(3),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _remedeMaladieService.getRemedesAndMaladies(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Aucun remède trouvé.'));
            }

            // Filtrage des résultats de recherche
            final remedesMaladies = snapshot.data!
                .where((remedeMaladie) =>
                    remedeMaladie['remede']['nom']
                        .toLowerCase()
                        .contains(searchQuery) ||
                    remedeMaladie['maladie']['nom']
                        .toLowerCase()
                        .contains(searchQuery))
                .toList();

            if (remedesMaladies.isEmpty) {
              return Center(child: Text('Aucun résultat pour "$searchQuery"'));
            }

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(2), // Nom du remède
                  1: FlexColumnWidth(2), // Maladie associée
                  2: FlexColumnWidth(3), // Description
                  3: FlexColumnWidth(2), // Utilisation
                  4: FlexColumnWidth(3), // Image
                  5: FlexColumnWidth(1), // Actions
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    children: [
                      _buildTableHeader('Nom Remède'),
                      _buildTableHeader('Maladie Associée'),
                      _buildTableHeader('Description Résumée'),
                      _buildTableHeader('Utilisation'),
                      _buildTableHeader('Image'),
                      _buildTableHeader('Actions'),
                    ],
                  ),
                  ...remedesMaladies.map((remedeMaladie) {
                    final remede = remedeMaladie['remede'];
                    final maladie = remedeMaladie['maladie'];

                    print(
                        'Remede: ${remede['nom']}, Ref: ${remede['remede_ref']}');
                    print(
                        'Maladie: ${maladie['nom']}, Ref: ${maladie['maladie_ref']}');

                    return TableRow(
                      decoration: BoxDecoration(
                        color: remedesMaladies.indexOf(remedeMaladie).isEven
                            ? Colors.white
                            : Colors.grey[100],
                      ),
                      children: [
                        _buildTableCell(remede['nom']),
                        _buildTableCell(maladie['nom']),
                        _buildTableCell(
                            _getShortDescription(remede['description'])),
                        _buildTableCell(remede['utilisation']),
                        _buildImageCell(remede['image']),
                        _buildActionIcons(remede, maladie),
                      ],
                    );
                  }).toList(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _getShortDescription(String description) {
    return description.length > 50
        ? '${description.substring(0, 50)}...'
        : description;
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          fontFamily: 'Poppins',
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
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'Poppins',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildImageCell(String imageUrl) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Image.network(
        imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.image_not_supported, color: Colors.grey);
        },
      ),
    );
  }

  Widget _buildActionIcons(
      Map<String, dynamic> remede, Map<String, dynamic> maladie) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: IconButton(
              icon: const Icon(Icons.remove_red_eye, color: Colors.green),
              onPressed: () {
                _showRemedeDetails(remede);
              },
            ),
          ),
          Flexible(
            child: IconButton(
              icon: const Icon(Icons.link_off, color: Colors.red),
              onPressed: () async {
                await _dissocierRemedeMaladie(remede, maladie);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showRemedeDetails(Map<String, dynamic> remede) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(remede['nom']),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Description : ${remede['description']}'),
                const SizedBox(height: 10),
                Text('Utilisation : ${remede['utilisation']}'),
              ],
            ),
          ),
        );
      },
    );
  }

 Future<void> _dissocierRemedeMaladie(
    Map<String, dynamic> remede, Map<String, dynamic> maladie) async {
  
  print('Tentative de dissociation...');
  final remedeRef = remede['remede_ref'] ?? 'Référence Remède Invalide';
  final maladieRef = maladie['maladie_ref'] ?? 'Référence Maladie Invalide';
  
  print('Remede Ref: $remedeRef, Maladie Ref: $maladieRef');

  if (remede['remede_ref'] == null) {
    print('Erreur: Remede Ref est null.');
    return;
  }
  if (maladie['maladie_ref'] == null) {
    print('Erreur: Maladie Ref est null.');
    return;
  }

  await _remedeMaladieService.dissocierRemedeMaladie(remedeRef, maladieRef);
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Le remède a été dissocié de la maladie.')),
  );
}
}
