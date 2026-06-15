import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:campus_connect/models/post_model.dart';
import 'package:campus_connect/services/post_service.dart';
import 'package:campus_connect/screens/createpost/comments_screen.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final postService = PostService();
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<List<PostModel>>(
      stream: postService.getFeedStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.dynamic_feed_outlined,
                    size: 40, color: Colors.indigo.shade300),
                ),
                const SizedBox(height: 16),
                const Text('No posts yet',
                  style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text('Be the first to post something!',
                  style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade500)),
              ],
            ),
          );
        }

        final posts = snapshot.data!;

        return RefreshIndicator(
          color: Colors.indigo,
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView.separated(
            itemCount: posts.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, thickness: 0.5),
            itemBuilder: (context, index) {
              final post = posts[index];
              final isLiked = post.likes.contains(currentUid);
              return PostCard(
                post: post,
                isLiked: isLiked,
                onLike: () => postService.toggleLike(post.id, post.likes),
              );
            },
          ),
        );
      },
    );
  }
}

class PostCard extends StatelessWidget {
  final PostModel post;
  final bool isLiked;
  final VoidCallback onLike;

  const PostCard({
    super.key,
    required this.post,
    required this.isLiked,
    required this.onLike,
  });

  Color _avatarColor(String name) {
    final colors = [
      Colors.indigo, Colors.pink, Colors.teal,
      Colors.orange, Colors.purple, Colors.green,
    ];
    return colors[name.length % colors.length];
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _avatarColor(post.authorName),
                child: Text(_initials(post.authorName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(
                      '${post.authorBranch} • ${post.authorYear} · ${timeago.format(post.createdAt)}',
                      style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              if (post.community != 'General')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(post.community,
                    style: const TextStyle(
                      fontSize: 10, color: Colors.indigo)),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Content
          Text(post.content,
            style: const TextStyle(fontSize: 14, height: 1.4)),
          const SizedBox(height: 10),

          // Actions
          Row(
            children: [
              GestureDetector(
                onTap: onLike,
                child: Row(
                  children: [
                    Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: isLiked ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text('${post.likes.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isLiked ? Colors.red : Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CommentsScreen(
                      postId: post.id,
                      postContent: post.content,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline,
                      size: 18, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${post.commentCount}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(Icons.bookmark_border,
                size: 18, color: Colors.grey),
              
              if (post.authorId == FirebaseAuth.instance.currentUser!.uid)
                GestureDetector(
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Delete Post'),
                        content: const Text('Are you sure you want to delete this post?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel')),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete',
                              style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await PostService().deletePost(post.id);
                    }
                  },
                  child: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                ),
            ],
          ),
        ],
      ),
    );
  }
}