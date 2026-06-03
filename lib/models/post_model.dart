import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String authorBranch;
  final String authorYear;
  final String content;
  final List<String> likes;
  final int commentCount;
  final String community;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorBranch,
    required this.authorYear,
    required this.content,
    required this.likes,
    required this.commentCount,
    required this.community,
    required this.createdAt,
  });

  factory PostModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      authorBranch: data['authorBranch'] ?? '',
      authorYear: data['authorYear'] ?? '',
      content: data['content'] ?? '',
      likes: List<String>.from(data['likes'] ?? []),
      commentCount: data['commentCount'] ?? 0,
      community: data['community'] ?? 'General',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}