import 'package:cloud_firestore/cloud_firestore.dart';

class CloudFirestoreService {
  final FirebaseFirestore db;

  const CloudFirestoreService(this.db);

  Future<void> add(String collectionName, String docId, Map<String, dynamic> data) async {
    // Add a new document with a generated ID
    try {
      await db.collection(collectionName).doc(docId).set(data);
    } catch (error) {
      print("Failed to add document: $error");
    }
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

  Future<List> fetchUsers(String s) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    List userList = [];
    return users.get()
      .then((QuerySnapshot snapshot) {
        for (var doc in snapshot.docs) {
          userList.add(doc.id);
        }
        return userList;
      })
      // ignore: invalid_return_type_for_catch_error
      .catchError((error) => print(error));
  }

  Future<void> update(String collection, String docId, Map<String, dynamic> data) async {
    try {
      await db.collection(collection).doc(docId).update(data);
    } catch (error) {
      print("Failed to update document: $error");
    }
  }
}