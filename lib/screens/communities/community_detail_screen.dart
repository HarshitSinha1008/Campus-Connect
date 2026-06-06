import 'package:flutter/material.dart';
import 'package:campus_connect/models/community_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
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
        ],
      ),
    );
  }
}