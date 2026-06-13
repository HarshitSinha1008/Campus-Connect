import 'package:flutter/material.dart';
import 'package:campus_connect/models/post_model.dart';
import 'package:campus_connect/services/post_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_connect/screens/feed/feed_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({super.key});

  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  String _search = '';
  final currentUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //search bar
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            onChanged: (val) => setState(() => _search = val),
            decoration: InputDecoration(
              hintText: 'Search posts...',
              hintStyle: const TextStyle(fontSize: 13),
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),

        //Result
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder:(context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final allPosts = snapshot.data!.docs
                .map((doc) => PostModel.fromDoc(doc))
                .toList();

              // Filter by search
              final filtered = _search.isEmpty ? allPosts : 
                allPosts.where((p) => p.content.toLowerCase().contains(_search.toLowerCase()) ||
                p.authorName.toLowerCase().contains(_search.toLowerCase()) ||
                p.community.toLowerCase().contains(_search.toLowerCase())).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off,
                        size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(_search.isEmpty
                        ? 'No posts found'
                        : 'No results for "$_search"',
                      style: TextStyle(
                        color: Colors.grey.shade500
                      )),
                    ],
                  ),
                );
              }

              return ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_,__) => const Divider(height: 1, thickness: 0.5),
                itemBuilder: (context, index) {
                  final post = filtered[index];
                  final isLiked = post.likes.contains(currentUid);
                  return PostCard(
                    post: post,
                    isLiked: isLiked,
                    onLike: () => PostService().toggleLike(post.id, post.likes)
                  );
                }
              );  
            },
          ),
        ),
      ],
    );
  }
}