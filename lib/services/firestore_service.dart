import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

Future<void> addServiceRequest({
  required String userId,
  String? landlordId,  
  required String title,
  required String description,
  required String location,
  required String category,
  required String urgency,
  required String status,
  required DateTime date,
  required String roomNumber,
}) async {
  await _db.collection('service_requests').add({
    'userId': userId,
    'landlordId': landlordId,
    'title': title,
    'description': description,
    'location': location,
    'category': category,
    'urgency': urgency,
    'status': status,
    'date': date,
    'roomNumber': roomNumber,
  });
}


  Stream<QuerySnapshot> getUserRequests(String userId) {
    return _db
        .collection('service_requests')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots();
  }
}

