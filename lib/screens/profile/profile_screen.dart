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
                    final posts = postSnap.data ?? [];
                    final totalLikes = posts.fold<int>(
                      0, (sum, p) => sum + p.likes.length);
                    
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          // Settings icon row
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.logout_outlined),
                                  onPressed: () async {
                                    await AuthService().logout();
                                    if (context.mounted) {
                                      Navigator.pushAndRemoveUntil(
                                        context, 
                                        MaterialPageRoute(
                                          builder: (_) => const LoginScreen(),
                                        ),
                                        (route) => false
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),

                          // Profile header card
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                                    child: Text(_initials(name),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600
                                    ),
                                  ), 
                                  ),
                                  const SizedBox(width: 14), 
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                        )),
                                        const SizedBox(height: 2),
                                        Text('$branch • $year',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.85),
                                          fontSize: 12,
                                        )),
                                        Text(email,
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.7),
                                            fontSize: 11,
                                          )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Stats row
                        ],
                      ),
                    );
                }
            );
        }
    );
  }
}