import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campus_connect/models/post_model.dart';

class PostService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

//get all posts for the feed, ordered by creation time
  Stream<List<PostModel>> getFeedStream() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(PostModel.fromDoc).toList());
  }

//create a new post
  Future<void> createPost({
    required String content,
    required String community,
  }) async {
    final user = _auth.currentUser!;

    // Get user profile from Firestore
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data() as Map<String, dynamic>;

    // Create a new post document in Firestore
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

  // Toggle like a post

  Future<void> toggleLike(String postId, List<String> currentLikes) async {
    final uid = _auth.currentUser!.uid;
    final ref = _firestore.collection('posts').doc(postId);

    if (currentLikes.contains(uid)) {
      // If already liked, remove the like
      await ref.update({
        'likes': FieldValue.arrayRemove([uid])
      });
    } else {
      // If not liked, add the like
      await ref.update({
        'likes': FieldValue.arrayUnion([uid])
      });
    }
  }
}