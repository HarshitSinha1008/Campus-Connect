import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late String _selectedBranch;
  late String _selectedYear;
  late TextEditingController _bioController;

  File? _pickedImage;
  String? _existingPhotoUrl;
  bool _isSaving = false;

  final _branches = ['CSE', 'ECE', 'ME', 'CE', 'EE', 'IT', 'MBA', 'Other'];
  final _years = ['1st Year', '2nd Year', '3rd Year', '4th Year'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
        text: widget.userData['name'] ?? '');
    _bioController = TextEditingController(
        text: widget.userData['bio'] ?? '');
    _selectedBranch = widget.userData['branch'] ?? 'CSE';
    _selectedYear = widget.userData['year'] ?? '1st Year';
    _existingPhotoUrl = widget.userData['photoUrl'];
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 400,
    );
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<String?> _encodeImage() async {
    if (_pickedImage == null) return _existingPhotoUrl;
    final bytes = await _pickedImage!.readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final photoData = await _encodeImage();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({
        'name': _nameController.text.trim(),
        'branch': _selectedBranch,
        'year': _selectedYear,
        'bio': _bioController.text.trim(),
        if (photoData != null) 'photoUrl': photoData,
      });

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')));
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save',
                    style: TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Avatar picker
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.indigo,
                    backgroundImage: _pickedImage != null
                        ? FileImage(_pickedImage!)
                        : (_existingPhotoUrl != null
                            ? MemoryImage(base64Decode(_existingPhotoUrl!))
                            : null) as ImageProvider?,
                    child: (_pickedImage == null && _existingPhotoUrl == null)
                        ? Text(
                            _initials(_nameController.text),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w600),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: Colors.indigo,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: TextButton(
                onPressed: _pickImage,
                child: const Text('Change Photo',
                  style: TextStyle(color: Colors.indigo, fontSize: 13)),
              ),
            ),
            const SizedBox(height: 16),

            // Name
            const Text('Full Name',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // Email (read only)
            const Text('College Email',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                widget.userData['email'] ?? '',
                style: TextStyle(
                  fontSize: 14, color: Colors.grey.shade500)),
            ),
            const SizedBox(height: 16),

            // Branch + Year side by side
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Branch',
                        style: TextStyle(fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedBranch,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        ),
                        items: _branches.map((b) =>
                          DropdownMenuItem(value: b, child: Text(b))).toList(),
                        onChanged: (val) =>
                          setState(() => _selectedBranch = val!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Year',
                        style: TextStyle(fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedYear,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        ),
                        items: _years.map((y) =>
                          DropdownMenuItem(value: y, child: Text(y))).toList(),
                        onChanged: (val) =>
                          setState(() => _selectedYear = val!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Bio
            const Text('Bio',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 6),
            TextField(
              controller: _bioController,
              maxLines: 3,
              maxLength: 120,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Tell something about yourself...',
                hintStyle: TextStyle(fontSize: 13),
                contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}