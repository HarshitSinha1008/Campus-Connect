import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

class CommunityService {
  final _firestore = FirebaseFirestore.instance;

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
}