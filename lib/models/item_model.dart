import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String id;
  final String sellerId;
  final String sellerName;
  final String sellerContact;
  final String description;
  final String itemType;
  final String? imageBase64;
  final DateTime createdAt;

  ItemModel({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.sellerContact,
    required this.description,
    required this.itemType,
    this.imageBase64,
    required this.createdAt,
  });

  factory ItemModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ItemModel(
      id: doc.id,
      sellerId: data['sellerId'] ?? '',
      sellerName: data['sellerName'] ?? '',
      sellerContact: data['sellerContact'] ?? '',
      description: data['description'] ?? '',
      itemType: data['itemType'] ?? 'Other',
      imageBase64: data['imageBase64'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}