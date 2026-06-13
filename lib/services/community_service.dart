import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campus_connect/models/post_model.dart';

class CommunityService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Get posts filtered by community
  Stream<List<PostModel>> getCommunityFeedStream(String communityId) {
    return _firestore
        .collection('posts')
        .where('community', isEqualTo: communityId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => PostModel.fromDoc(doc))
            .toList());
  }

  // Get member count as real-time stream
  Stream<int> getMemberCountStream(String communityId) {
    return _firestore
        .collection('communities')
        .doc(communityId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return 0;
          final data = doc.data() as Map<String, dynamic>;
          final members = List<String>.from(data['memberIds'] ?? []);
          return members.length;
        });
  }

  // Check if current user has joined
  Stream<bool> isJoinedStream(String communityId) {
    final uid = _auth.currentUser!.uid;
    return _firestore
        .collection('communities')
        .doc(communityId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return false;
          final data = doc.data() as Map<String, dynamic>;
          final members = List<String>.from(data['memberIds'] ?? []);
          return members.contains(uid);
        });
  }

  // Join or leave a community
  Future<void> toggleJoin(String communityId, bool isJoined) async {
    final uid = _auth.currentUser!.uid;
    final ref = _firestore.collection('communities').doc(communityId);

    final doc = await ref.get();

    if (!doc.exists) {
      // Create the document first
      await ref.set({'memberIds': []});
    }

    if (isJoined) {
      await ref.update({
        'memberIds': FieldValue.arrayRemove([uid])
      });
    } else {
      await ref.update({
        'memberIds': FieldValue.arrayUnion([uid])
      });
    }
  }
}