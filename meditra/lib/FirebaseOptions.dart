import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: "AIzaSyBltF1XpjT51-sZsx8587Y75STDyfwInD0", // Votre API Key Web
      appId: "1:742728669682:android:9e52c59f3407e77da6f36b",
      messagingSenderId: "742728669682",
      projectId: "meditra-7d914",
      storageBucket: "meditra-7d914.appspot.com",
    );
  }
}
