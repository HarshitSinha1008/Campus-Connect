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

  //get data from firestore
  factory PostModel.fromMap(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      authorBranch: map['authorBranch'] ?? '',
      authorYear: map['authorYear'] ?? '',
      content: map['content'] ?? '',
      likes: List<String>.from(map['likes'] ?? []),
      commentCount: map['commentCount'] ?? 0,
      community: map['community'] ?? '',
      createdAt: map['createdAt'].toDate() ?? DateTime.now(),
    );
  }
}