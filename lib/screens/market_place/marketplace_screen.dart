import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:campus_connect/models/item_model.dart';
import 'package:campus_connect/services/marketplace_service.dart';
import 'add_item.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final _marketplaceService = MarketplaceService();
  final _currentUid = FirebaseAuth.instance.currentUser!.uid;
  String _selectedFilter = 'All';

  final _filters = [
    'All', 'Books', 'Electronics', 'Clothing',
    'Sports', 'Furniture', 'Stationery', 'Other'
  ];

  Color _typeColor(String type) {
    switch (type) {
      case 'Books': return Colors.blue;
      case 'Electronics': return Colors.indigo;
      case 'Clothing': return Colors.pink;
      case 'Sports': return Colors.red;
      case 'Furniture': return Colors.orange;
      case 'Stationery': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'Books': return Icons.menu_book;
      case 'Electronics': return Icons.devices;
      case 'Clothing': return Icons.checkroom;
      case 'Sports': return Icons.sports_soccer;
      case 'Furniture': return Icons.chair;
      case 'Stationery': return Icons.edit;
      default: return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black),
            children: [
              TextSpan(text: 'Campus'),
              TextSpan(text: 'Market',
                style: TextStyle(color: Colors.indigo)),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined,
              color: Colors.indigo),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddItemScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedFilter = filter),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.indigo : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(filter,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white : Colors.grey.shade600)),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),

          // Items grid
          Expanded(
            child: StreamBuilder<List<ItemModel>>(
              stream: _marketplaceService.getItemsStream(
                filterType: _selectedFilter),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator());
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
                          child: Icon(Icons.storefront_outlined,
                            size: 40,
                            color: Colors.indigo.shade300),
                        ),
                        const SizedBox(height: 16),
                        const Text('No items listed yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Be the first to list something!',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddItemScreen()),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('List an Item'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final items = snapshot.data!;

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _ItemCard(
                      item: item,
                      isOwner: item.sellerId == _currentUid,
                      typeColor: _typeColor(item.itemType),
                      typeIcon: _typeIcon(item.itemType),
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Delete Listing'),
                            content: const Text(
                              'Remove this item from marketplace?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('Cancel')),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text('Delete',
                                  style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await _marketplaceService.deleteItem(item.id);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final ItemModel item;
  final bool isOwner;
  final Color typeColor;
  final IconData typeIcon;
  final VoidCallback onDelete;

  const _ItemCard({
    required this.item,
    required this.isOwner,
    required this.typeColor,
    required this.typeIcon,
    required this.onDelete,
  });

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Image
                if (item.imageBase64 != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      base64Decode(item.imageBase64!),
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),

                // Type chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(typeIcon, size: 14, color: typeColor),
                      const SizedBox(width: 4),
                      Text(item.itemType,
                        style: TextStyle(
                          fontSize: 12,
                          color: typeColor,
                          fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                Text('Description',
                  style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade500)),
                const SizedBox(height: 4),
                Text(item.description,
                  style: const TextStyle(
                    fontSize: 14, height: 1.5)),
                const SizedBox(height: 16),

                // Seller info
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
                      Text('Seller',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.indigo,
                            child: Text(
                              item.sellerName.isNotEmpty
                                  ? item.sellerName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(item.sellerName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                                Text(item.sellerContact,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.indigo.shade400)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12)),
              child: item.imageBase64 != null
                  ? Image.memory(
                      base64Decode(item.imageBase64!),
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 130,
                      color: Colors.grey.shade100,
                      child: Icon(typeIcon,
                        size: 40, color: Colors.grey.shade300),
                    ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(item.itemType,
                      style: TextStyle(
                        fontSize: 10,
                        color: typeColor,
                        fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 4),

                  // Description
                  Text(item.description,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),

                  // Seller + delete
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.sellerName,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      ),
                      if (isOwner)
                        GestureDetector(
                          onTap: onDelete,
                          child: const Icon(Icons.delete_outline,
                            size: 16, color: Colors.red)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}