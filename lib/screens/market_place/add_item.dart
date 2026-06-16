import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:campus_connect/services/marketplace_service.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _descriptionController = TextEditingController();
  final _contactController = TextEditingController();
  final _marketplaceService = MarketplaceService();

  String _selectedType = 'Books';
  File? _pickedImage;
  bool _isPosting = false;

  final _itemTypes = [
    'Books', 'Electronics', 'Clothing',
    'Sports', 'Furniture', 'Stationery', 'Other'
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 600,
    );
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a description')));
      return;
    }
    if (_contactController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add contact info')));
      return;
    }

    setState(() => _isPosting = true);

    try {
      String? imageBase64;
      if (_pickedImage != null) {
        final bytes = await _pickedImage!.readAsBytes();
        imageBase64 = base64Encode(bytes);
      }

      await _marketplaceService.addItem(
        description: _descriptionController.text.trim(),
        itemType: _selectedType,
        sellerContact: _contactController.text.trim(),
        imageBase64: imageBase64,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isPosting = false);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List an Item'),
        actions: [
          TextButton(
            onPressed: _isPosting ? null : _submit,
            child: _isPosting
                ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Post',
                    style: TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Image picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    style: BorderStyle.solid),
                ),
                child: _pickedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_pickedImage!,
                          fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                            size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text('Tap to add photo',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Item type
            const Text('Item Type',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
              ),
              items: _itemTypes.map((t) =>
                DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) => setState(() => _selectedType = val!),
            ),
            const SizedBox(height: 16),

            // Description
            const Text('Description',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 6),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              maxLength: 300,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Describe your item, condition, price...',
                hintStyle: TextStyle(fontSize: 13),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // Contact info
            const Text('Contact Info',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 6),
            TextField(
              controller: _contactController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Phone number, WhatsApp, Instagram...',
                hintStyle: TextStyle(fontSize: 13),
                prefixIcon: Icon(Icons.contact_phone_outlined),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}