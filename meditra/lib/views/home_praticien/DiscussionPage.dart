import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:meditra/config/config.dart';

class DiscussionPage extends StatefulWidget {
  final String discussionId;

  const DiscussionPage({Key? key, required this.discussionId})
      : super(key: key);

  @override
  _DiscussionPageState createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isSending = false;
  Future<void> _sendMessage(String message, {String? imageUrl}) async {
  if (_isSending) return; // Pour éviter plusieurs envois en même temps
  setState(() {
    _isSending = true;
  });
  Future.microtask(() async => await _sendMessage(_messageController.text));

  try {
    String currentUserId = _auth.currentUser?.uid ?? '';
    await _firestore
        .collection('discussions')
        .doc(widget.discussionId)
        .collection('messages')
        .add({
      'senderId': currentUserId,
      'message': message,
      'imageUrl': imageUrl,
      'sentAt': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  } catch (e) {
    print("Erreur lors de l'envoi du message : $e");
  } finally {
    // Petite temporisation pour permettre à l'interface de se stabiliser
    await Future.delayed(Duration(milliseconds: 200));
    setState(() {
      _isSending = false;
    });
  }
}

  Future<void> _pickImage() async {
    final pickedFile = await showDialog<XFile>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choisissez une source'),
        actions: [
          TextButton(
            onPressed: () async {
              final image =
                  await _imagePicker.pickImage(source: ImageSource.camera);
              Navigator.of(context).pop(image);
            },
            child: Text('Caméra'),
          ),
          TextButton(
            onPressed: () async {
              final image =
                  await _imagePicker.pickImage(source: ImageSource.gallery);
              Navigator.of(context).pop(image);
            },
            child: Text('Galerie'),
          ),
        ],
      ),
    );

    if (pickedFile != null) {
      String fileName = pickedFile.name;
      File imageFile = File(pickedFile.path);

      try {
        TaskSnapshot snapshot =
            await _storage.ref('images/$fileName').putFile(imageFile);
        String downloadUrl = await snapshot.ref.getDownloadURL();
        _sendMessage('', imageUrl: downloadUrl);
      } catch (e) {
        print("Erreur lors du téléchargement de l'image: $e");
      }
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    await _firestore
        .collection('discussions')
        .doc(widget.discussionId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  Future<void> _editMessage(String messageId, String currentMessage) async {
    // Déclaration du TextEditingController
    TextEditingController controller =
        TextEditingController(text: currentMessage);

    String? editedMessage = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Modifier le message',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          content: TextField(
            controller: controller, // Utilisation du contrôleur ici
            decoration: InputDecoration(
              hintText: 'Entrez votre message',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Vérification que le texte n'est pas vide avant de le retourner
                Navigator.of(context)
                    .pop(controller.text.isNotEmpty ? controller.text : null);
              },
              child: Text('Modifier'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
          ],
        );
      },
    );

    if (editedMessage != null && editedMessage.isNotEmpty) {
      await _firestore
          .collection('discussions')
          .doc(widget.discussionId)
          .collection('messages')
          .doc(messageId)
          .update({'message': editedMessage});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text("Discussion"),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('discussions')
                  .doc(widget.discussionId)
                  .collection('messages')
                  .orderBy('sentAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var messageData =
                        messages[index].data() as Map<String, dynamic>;
                    String messageId = messages[index].id;
                    bool isCurrentUser =
                        messageData['senderId'] == _auth.currentUser?.uid;

                    DateTime sentAt =
                        (messageData['sentAt'] as Timestamp).toDate();

                    return GestureDetector(
                      onLongPress: () {
                        if (isCurrentUser) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Options'),
                              actions: [
                                TextButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _editMessage(
                                        messageId, messageData['message']);
                                  },
                                  icon: Icon(Icons.check, color: Colors.blue),
                                  label: Text('Modifier',
                                      style: TextStyle(color: Colors.blue)),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _deleteMessage(messageId);
                                  },
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  label: Text('Supprimer',
                                      style: TextStyle(color: Colors.red)),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  icon: Icon(Icons.cancel, color: Colors.grey),
                                  label: Text('Annuler',
                                      style: TextStyle(color: Colors.grey)),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: Column(
                        crossAxisAlignment: isCurrentUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (index == messages.length - 1 ||
                              DateFormat('yMMMd').format(
                                      (messages[index]['sentAt'] as Timestamp)
                                          .toDate()) !=
                                  DateFormat('yMMMd').format(
                                      (messages[index + 1]['sentAt']
                                              as Timestamp)
                                          .toDate()))
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: Container(
                                  constraints: BoxConstraints(maxWidth: 100),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      DateFormat('yMMMd').format(sentAt),
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          _buildMessageBubble(
                            messageData['message'],
                            isCurrentUser,
                            sentAt,
                            imageUrl: messageData['imageUrl'],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
      String message, bool isCurrentUser, DateTime sentAt,
      {String? imageUrl}) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: isCurrentUser ? couleurSecondaire : Colors.grey[300],
          borderRadius: isCurrentUser
              ? BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                )
              : BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (imageUrl != null) Image.network(imageUrl),
            Text(
              message,
              style: TextStyle(
                color: isCurrentUser ? Colors.black : Colors.black,
              ),
            ),
            Text(
              DateFormat('HH:mm').format(sentAt),
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildMessageInputField() {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      children: [
        IconButton(
          icon: Icon(Icons.photo, color: couleurPrincipale),
          onPressed: _pickImage,
        ),
        Expanded(
          child: TextField(
            controller: _messageController,
            decoration: InputDecoration(
              hintText: 'Écrivez votre message...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
        _isSending
            ? CircularProgressIndicator() // Indicateur de chargement pendant l'envoi
            : IconButton(
                icon: Icon(Icons.send, color: couleurPrincipale),
                onPressed: _isSending
                    ? null // Désactive le bouton s'il est en train d'envoyer
                    : () {
                        if (_messageController.text.isNotEmpty) {
                          _sendMessage(_messageController.text);
                        }
                      },
              ),
      ],
    ),
  );
}
}
