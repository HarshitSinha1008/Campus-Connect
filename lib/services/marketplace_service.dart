import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/item_model.dart';

class MarketplaceService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Get all items as real-time stream
  Stream<List<ItemModel>> getItemsStream({String? filterType}) {
    Query query = _firestore
        .collection('marketplace')
        .orderBy('createdAt', descending: true);

    if (filterType != null && filterType != 'All') {
      query = query.where('itemType', isEqualTo: filterType);
    }

    return query.snapshots().map((snap) =>
        snap.docs.map((doc) => ItemModel.fromDoc(doc)).toList());
  }

  // Add a new item listing
  Future<void> addItem({
    required String description,
    required String itemType,
    required String sellerContact,
    String? imageBase64,
  }) async {
    final uid = _auth.currentUser!.uid;
    final userDoc = await _firestore
        .collection('users').doc(uid).get();
    final userData = userDoc.data() as Map<String, dynamic>;

    await _firestore.collection('marketplace').add({
      'sellerId': uid,
      'sellerName': userData['name'],
      'sellerContact': sellerContact,
      'description': description,
      'itemType': itemType,
      'imageBase64': imageBase64,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete an item
  Future<void> deleteItem(String itemId) async {
    await _firestore.collection('marketplace').doc(itemId).delete();
  }
}