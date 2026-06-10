import 'package:flutter/material.dart';
import 'package:campus_connect/models/community_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/community_service.dart';
import '../../models/post_model.dart';
import '../../services/post_service.dart';
import 'package:campus_connect/screens/feed/feed_screen.dart';
import 'package:campus_connect/screens/createpost/create_post_screen.dart';

class CommunityDetailScreen extends StatelessWidget {
  final CommunityModel community;

  const CommunityDetailScreen({super.key, required this.community});

  @override
  Widget build(BuildContext context) {
    final communityService = CommunityService();
    final postService = PostService();
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Column(
        children: [
          // Community header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: community.color,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    community.icon,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(community.name, style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold
                      )),
                      Text(
                        '${community.membersCount} members',
                        style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500
                        )
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          //Tabs
          DefaultTabController(
            length: 2,
            child: Expanded(child: Column(
              children:[
                TabBar(
                  labelColor: Colors.indigo,
                  indicatorColor: Colors.indigo,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: 'Posts'),
                    Tab(text: 'About'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // posts tab
                      StreamBuilder<List<PostModel>>(
                        stream: communityService.getCommunityFeedStream(community.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text(
                                'No posts yet. Start by creating one!',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
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
                            },
                          );
                        },
                      ),

                      // about tab
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
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
                                      color: Colors.grey.shade700
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(community.description, style: const TextStyle(fontSize: 13, height: 1.4)),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.people_outline,
                                        color: Colors.grey.shade500,
                                        size: 16,),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${community.membersCount} members',
                                        style: TextStyle(
                                          fontSize: 12, color: Colors.grey.shade500
                                        )
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),  
              ],
            )
          ))
        ],
      ),
    );
  }
}