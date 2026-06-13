import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campus_connect/models/community_model.dart';
import 'package:campus_connect/models/post_model.dart';
import 'package:campus_connect/services/community_service.dart';
import 'package:campus_connect/services/post_service.dart';
import 'package:campus_connect/screens/feed/feed_screen.dart';
import 'package:campus_connect/screens/createpost/create_post_screen.dart';

class CommunityDetailScreen extends StatelessWidget {
  final CommunityModel community;

  const CommunityDetailScreen({super.key, required this.community});

  @override
  Widget build(BuildContext context) {
    final communityService = CommunityService();
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // Community header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: community.color,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(community.icon,
                      color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(community.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),

                        // Dynamic member count
                        StreamBuilder<int>(
                          stream: communityService
                              .getMemberCountStream(community.id),
                          builder: (context, snapshot) {
                            final count = snapshot.data ?? 0;
                            return Text('$count members',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500));
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // TabBar
            const TabBar(
              labelColor: Colors.indigo,
              indicatorColor: Colors.indigo,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'Posts'),
                Tab(text: 'About'),
              ],
            ),

            // TabBarView
            Expanded(
              child: TabBarView(
                children: [
                  // Posts tab
                  StreamBuilder<List<PostModel>>(
                    stream: communityService
                        .getCommunityFeedStream(community.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                              Text('Be the first to post here!',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500)),
                            ],
                          ),
                        );
                      }
                      final posts = snapshot.data!;
                      return ListView.separated(
                        itemCount: posts.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, thickness: 0.5),
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          final isLiked =
                              post.likes.contains(currentUid);
                          return PostCard(
                            post: post,
                            isLiked: isLiked,
                            onLike: () => PostService()
                                .toggleLike(post.id, post.likes),
                          );
                        },
                      );
                    },
                  ),

                  // About tab
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('About this community',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700)),
                          const SizedBox(height: 8),
                          Text(community.description,
                            style: const TextStyle(
                              fontSize: 13, height: 1.4)),
                          const SizedBox(height: 12),

                          // Dynamic member count in about tab too
                          StreamBuilder<int>(
                            stream: communityService
                                .getMemberCountStream(community.id),
                            builder: (context, snapshot) {
                              final count = snapshot.data ?? 0;
                              return Row(
                                children: [
                                  Icon(Icons.people_outline,
                                    size: 16,
                                    color: Colors.grey.shade500),
                                  const SizedBox(width: 6),
                                  Text('$count members',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500)),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Dynamic Join / Leave button
      bottomNavigationBar: StreamBuilder<bool>(
        stream: communityService.isJoinedStream(community.id),
        builder: (context, snapshot) {
          final isJoined = snapshot.data ?? false;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: () async {
                await communityService.toggleJoin(
                  community.id, isJoined);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isJoined
                        ? 'Left ${community.name}'
                        : 'Joined ${community.name}!'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isJoined ? Colors.grey.shade200 : Colors.indigo,
                foregroundColor:
                    isJoined ? Colors.grey.shade700 : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                isJoined ? 'Leave Community' : 'Join Community',
                style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          );
        },
      ),
    );
  }
}