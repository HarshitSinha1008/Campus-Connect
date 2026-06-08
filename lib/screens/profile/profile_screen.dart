import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_connect/services/auth_service.dart';
import 'package:campus_connect/services/post_service.dart';
import 'package:campus_connect/models/post_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:campus_connect/screens/auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Color _avatarColor(String name) {
    final colors = [
      Colors.indigo, Colors.pink, Colors.teal, Colors.orange, Colors.purple, Colors.green,];
      return colors[name.length % colors.length];
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final postService = PostService();

    return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, userSnap) {
            if (!userSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
            }

            final user = userSnap.data!.data() as Map<String, dynamic>;
            final name = user['name'] ?? '';
            final email = user['email'] ?? '';
            final branch = user['branch'] ?? '';
            final year = user['year'] ?? '';

            return StreamBuilder<List<PostModel>>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .where('authorId', isEqualTo: uid)
                    .orderBy('createdAt', descending: true)
                    .snapshots()
                    .map((snap) => snap.docs.map((doc) => PostModel.fromDoc(doc)).toList()),
                builder: (context, postSnap) {
                    
                }
            );
        }
    );
  }
}