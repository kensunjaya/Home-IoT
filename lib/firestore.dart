import 'package:cloud_firestore/cloud_firestore.dart';

class CloudFirestoreService {
  final FirebaseFirestore db;

  const CloudFirestoreService(this.db);

  Future<void> add(String collectionName, String docId, Map<String, dynamic> data) async {
    // Add a new document with a generated ID
    await db.collection(collectionName).doc(docId).set(data);
  }

  Future<Map<String, dynamic>?> get(String collection, String docId) async {
    try {
      DocumentSnapshot snapshot = await db.collection(collection).doc(docId).get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>?;
      } else {
        print('No such document!');
        return null;
      }
    } catch (error) {
      print("Failed to fetch document: $error");
      return null;
    }
  }
}