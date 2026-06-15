import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:campus_connect/models/post_model.dart';
import 'package:campus_connect/services/auth_service.dart';
import 'edit_profile_screen.dart';
import 'package:campus_connect/screens/auth/login_screen.dart';
import 'package:campus_connect/screens/about_me/about_developer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {

  final String uid = FirebaseAuth.instance.currentUser!.uid;

  late final Stream<DocumentSnapshot> _userStream;
  late final Stream<QuerySnapshot> _postsStream;
  late final Stream<QuerySnapshot> _communitiesStream;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _userStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots();

    _postsStream = FirebaseFirestore.instance
        .collection('posts')
        .where('authorId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();

    _communitiesStream = FirebaseFirestore.instance
        .collection('communities')
        .where('memberIds', arrayContains: uid)
        .snapshots();

     FirebaseFirestore.instance
      .collection('posts')
      .where('authorId', isEqualTo: uid)
      .get()
      .then((snap) {
        print('DEBUG: uid = $uid');
        print('DEBUG: total posts found = ${snap.docs.length}');
        for (var doc in snap.docs) {
          print('DEBUG: post = ${doc.data()}');
        }
      });  
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder<DocumentSnapshot>(
      stream: _userStream,
      builder: (context, userSnap) {
        if (!userSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = userSnap.data!.data() as Map<String, dynamic>;
        final name = user['name'] ?? '';
        final branch = user['branch'] ?? '';
        final year = user['year'] ?? '';
        final email = user['email'] ?? '';

        return StreamBuilder<QuerySnapshot>(
          stream: _postsStream,
          builder: (context, postSnap) {
            // Keep previous data while loading to prevent flicker
            final docs = postSnap.data?.docs ?? [];
            final posts = docs
                .map((doc) => PostModel.fromDoc(doc))
                .toList();
            final totalLikes = posts.fold<int>(
                0, (sum, p) => sum + p.likes.length);

            return SingleChildScrollView(
              child: Column(
                children: [

                  // Header row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Profile',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditProfileScreen(
                                      userData: user),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.logout_outlined),
                              onPressed: () async {
                                await AuthService().logout();
                                if (mounted) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen()),
                                    (route) => false,
                                  );
                                }
                              },
                            ),
                          ],
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
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.3),
                            backgroundImage: user['photoUrl'] != null
                                ? MemoryImage(
                                    base64Decode(user['photoUrl']))
                                : null,
                            child: user['photoUrl'] == null
                                ? Text(_initials(name),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600))
                                : null,
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
                                    fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text('$branch • $year',
                                  style: TextStyle(
                                    color: Colors.white.withValues(
                                        alpha: 0.85),
                                    fontSize: 12)),
                                Text(email,
                                  style: TextStyle(
                                    color: Colors.white.withValues(
                                        alpha: 0.7),
                                    fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Bio
                  if (user['bio'] != null &&
                      user['bio'].toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                      child: Text(user['bio'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600),
                        textAlign: TextAlign.center),
                    ),
                  const SizedBox(height: 12),

                  // Stats row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _StatBox(
                          value: '${posts.length}',
                          label: 'Posts'),
                        _StatBox(
                          value: '$totalLikes',
                          label: 'Likes'),
                        StreamBuilder<QuerySnapshot>(
                          stream: _communitiesStream,
                          builder: (context, snap) {
                            final count = snap.data?.docs.length ?? 0;
                            return _StatBox(
                              value: '$count',
                              label: 'Communities');
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // My Posts label
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('My Posts',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Posts list or empty state
                  if (postSnap.connectionState == ConnectionState.waiting
                      && docs.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    )
                  else if (posts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Container(
                            width: 70, height: 70,
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(Icons.post_add,
                              size: 34,
                              color: Colors.indigo.shade300),
                          ),
                          const SizedBox(height: 12),
                          const Text('No posts yet',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('Your posts will appear here',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500)),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: posts.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, thickness: 0.5),
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.indigo.shade50,
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Text(post.community,
                                      style: const TextStyle(
                                        color: Colors.indigo,
                                        fontSize: 11)),
                                  ),
                                  const Spacer(),
                                  Text(timeago.format(post.createdAt),
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 10)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(post.content,
                                style: const TextStyle(fontSize: 13),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.favorite_border,
                                    size: 14,
                                    color: Colors.grey.shade400),
                                  const SizedBox(width: 4),
                                  Text('${post.likes.length}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade400)),
                                  const SizedBox(width: 12),
                                  Icon(Icons.chat_bubble_outline,
                                    size: 14,
                                    color: Colors.grey.shade400),
                                  const SizedBox(width: 4),
                                  Text('${post.commentCount}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade400)),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  // About Developer button
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AboutDeveloper()),
                      ),
                      icon: const Icon(Icons.person_outline, size: 18),
                      label: const Text('About Developer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.indigo,
                        side: const BorderSide(color: Colors.indigo),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: const Size(double.infinity, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;

  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Text(value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo)),
            const SizedBox(height: 2),
            Text(label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}