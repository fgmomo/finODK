import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Politique de Confidentialité',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontFamily: policeLato,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Politique de confidentialité',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                '''Chez [Nom de votre plateforme], nous attachons une grande importance à la confidentialité et à la protection des données personnelles de nos utilisateurs. Cette politique de confidentialité explique quelles informations nous collectons, comment nous les utilisons, les partageons, et comment vous pouvez exercer vos droits concernant vos données personnelles.

1. **Collecte des informations**
Nous collectons les informations suivantes :
- **Informations personnelles** : Lors de l'inscription, nous collectons des données telles que votre nom, adresse e-mail et informations de contact.
- **Contenu publié** : Si vous êtes praticien, nous collectons les informations relatives à vos articles et remèdes publiés.
- **Données d'utilisation** : Informations sur votre interaction avec la plateforme (pages consultées, actions effectuées, etc.).

2. **Utilisation des informations**
Les informations sont utilisées pour :
- Vous fournir un accès fluide et personnalisé à notre catalogue de remèdes traditionnels.
- Améliorer nos services en fonction de vos préférences et besoins.
- Faciliter les interactions entre utilisateurs et praticiens via des commentaires et des échanges.

3. **Partage des informations**
Nous ne partageons vos informations personnelles avec des tiers que dans les situations suivantes :
- **Fournisseurs de services** : Partage avec des prestataires techniques pour le bon fonctionnement de la plateforme.
- **Obligations légales** : En cas d'exigences légales ou pour protéger les droits et la sécurité des utilisateurs.
- **Utilisateurs de la plateforme** : Vos publications sont visibles par d'autres utilisateurs.

4. **Sécurité des données**
Nous prenons des mesures pour protéger vos données, mais nous ne pouvons garantir la sécurité totale des informations transmises en ligne.

5. **Vos droits**
Vous disposez des droits suivants :
- **Accès et rectification** : Vous pouvez demander l'accès et la modification de vos informations.
- **Suppression** : Vous pouvez demander la suppression de vos données personnelles sous certaines conditions.
- **Opposition** : Vous pouvez vous opposer à l'utilisation de vos données à des fins spécifiques, comme le marketing.

6. **Conservation des données**
Nous conservons vos informations aussi longtemps que nécessaire pour fournir nos services, conformément aux obligations légales.

7. **Modifications de la politique de confidentialité**
Nous nous réservons le droit de mettre à jour cette politique. Toute modification sera publiée sur cette page.

8. **Contact**
Pour toute question concernant cette politique, vous pouvez nous contacter à [email de contact].''',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Dernière mise à jour : [Date de mise à jour].',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Merci de votre confiance.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
