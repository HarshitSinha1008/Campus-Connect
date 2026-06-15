import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post_model.dart';

class PostService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Get all posts as real-time stream (newest first)
  Stream<List<PostModel>> getFeedStream() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => PostModel.fromDoc(doc)).toList());
  }

  Future<void> deletePost(String postId) async {
    await _firestore.collection('posts').doc(postId).delete();
  }

  // Create a new post
  Future<void> createPost({
    required String content,
    required String community,
  }) async {
    final user = _auth.currentUser!;

    // Get user profile from Firestore
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data() as Map<String, dynamic>;

    await _firestore.collection('posts').add({
      'authorId': user.uid,
      'authorName': userData['name'],
      'authorBranch': userData['branch'],
      'authorYear': userData['year'],
      'content': content,
      'likes': [],
      'commentCount': 0,
      'community': community,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Toggle like on a post
  Future<void> toggleLike(String postId, List<String> currentLikes) async {
    final uid = _auth.currentUser!.uid;
    final ref = _firestore.collection('posts').doc(postId);

    if (currentLikes.contains(uid)) {
      await ref.update({'likes': FieldValue.arrayRemove([uid])});
    } else {
      await ref.update({'likes': FieldValue.arrayUnion([uid])});
    }
  }
}