import 'package:flutter/material.dart';
import 'package:campus_connect/services/post_service.dart';
import 'package:campus_connect/models/post_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:firebase_auth/firebase_auth.dart';

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
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.post_add, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text('No posts yet. Start by creating one!', style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          );
        }

        final posts = snapshot.data!;

        return ListView.separated(
          itemCount: posts.length,
          separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.5),
          itemBuilder: (context, index) {
            final post = posts[index];
            final isLiked = post.likes.contains(currentUid);

            return PostCard(
              post: post,
              isLiked: isLiked,
              onLike: () => postService.toggleLike(post.id, post.likes),
            );
          }
        );
      }
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

  // Generate avatar color from name
  Color _avatarColor(String name) {
    final colors = [
      Colors.indigo, Colors.pink, Colors.teal, Colors.orange, Colors.purple, Colors.green,];
      return colors[name.length % colors.length];
  }

  String _initials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}