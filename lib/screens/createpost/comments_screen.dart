import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentsScreen extends StatefulWidget {
  final String postId;
  final String postContent;

  const CommentsScreen({
    super.key,
    required this.postId,
    required this.postContent,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _commentController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool _isSending = false;

  Future<void> _sendComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isSending = true);

    try {
      final uid = _auth.currentUser!.uid;
      final userDoc = await _firestore
          .collection('users').doc(uid).get();
      final userData = userDoc.data() as Map<String, dynamic>;

      // Add comment to subcollection
      await _firestore
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .add({
        'authorId': uid,
        'authorName': userData['name'],
        'authorBranch': userData['branch'],
        'content': _commentController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Increment comment count on post
      await _firestore
          .collection('posts')
          .doc(widget.postId)
          .update({
        'commentCount': FieldValue.increment(1),
      });

      _commentController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isSending = false);
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Color _avatarColor(String name) {
    final colors = [
      Colors.indigo, Colors.pink, Colors.teal,
      Colors.orange, Colors.purple, Colors.green,
    ];
    return colors[name.length % colors.length];
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          // Original post
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.indigo.shade50,
            child: Text(widget.postContent,
              style: const TextStyle(
                fontSize: 13, color: Colors.black87),
              maxLines: 3,
              overflow: TextOverflow.ellipsis),
          ),
          const Divider(height: 1),

          // Comments list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('posts')
                  .doc(widget.postId)
                  .collection('comments')
                  .orderBy('createdAt', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                          size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text('No comments yet',
                          style: TextStyle(color: Colors.grey.shade500)),
                        const SizedBox(height: 4),
                        Text('Be the first to comment!',
                          style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade400)),
                      ],
                    ),
                  );
                }

                final comments = snapshot.data!.docs;

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: comments.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, thickness: 0.5),
                  itemBuilder: (context, index) {
                    final data =
                        comments[index].data() as Map<String, dynamic>;
                    final name = data['authorName'] ?? '';
                    final createdAt =
                        (data['createdAt'] as Timestamp?)?.toDate() ??
                            DateTime.now();

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: _avatarColor(name),
                            child: Text(_initials(name),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12)),
                                    const SizedBox(width: 6),
                                    Text(data['authorBranch'] ?? '',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade500)),
                                    const Spacer(),
                                    Text(timeago.format(createdAt),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade400)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(data['content'] ?? '',
                                  style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Comment input box
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.only(
              left: 12, right: 12,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      hintStyle: const TextStyle(fontSize: 13),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _isSending ? null : _sendComment,
                  child: Container(
                    width: 40, height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.indigo,
                      shape: BoxShape.circle,
                    ),
                    child: _isSending
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.send,
                            color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}