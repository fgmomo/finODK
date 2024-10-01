import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontFamily: 'Lato', // Assure-toi que c'est la police que tu utilises
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Exemple de notification
            _buildNotificationItem(
              icon: Icons.notifications,
              title: 'Nouvelle mise à jour disponible',
              subtitle: 'Une nouvelle version de l\'application est disponible.',
              date: 'Aujourd\'hui',
              onTap: () {
                // Action à effectuer lors du clic sur la notification
              },
            ),
            _buildNotificationItem(
              icon: Icons.message,
              title: 'Nouveau message reçu',
              subtitle: 'Vous avez reçu un message de votre praticien.',
              date: 'Hier',
              onTap: () {
                // Action à effectuer lors du clic sur la notification
              },
            ),
            // Ajoute d'autres notifications ici
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: couleurPrincipale, // Ou une couleur qui correspond à ton design
                size: 40,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
