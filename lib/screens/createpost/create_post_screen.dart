import 'package:flutter/material.dart';
import 'package:campus_connect/services/post_service.dart';

class CreatePostScreen extends StatefulWidget {
  final String? preselectedCommunity;

  const CreatePostScreen({super.key, this.preselectedCommunity});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _contentController = TextEditingController();
  final _postService = PostService();
  late String _selectedCommunity;
  bool _isPosting = false;

  final _communities = [
    'General', 'CSE', 'ECE', 'ME', 'CE', 'MBA', 'Sports', 'Events'
  ];

  @override
  void initState() {
    super.initState();
    _selectedCommunity = widget.preselectedCommunity ?? 'General';
  }

  Future<void> _post() async {
    if (_contentController.text.trim().isEmpty) return;

    setState(() => _isPosting = true);
    try {
      await _postService.createPost(
        content: _contentController.text.trim(),
        community: _selectedCommunity,
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
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed: _isPosting ? null : _post,
            child: _isPosting
                ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Post',
                    style: TextStyle(color: Colors.indigo,
                      fontWeight: FontWeight.w600, fontSize: 16)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _contentController,
              maxLines: 6,
              maxLength: 500,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: "What's on your mind?",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              style: const TextStyle(fontSize: 15),
            ),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Post to community',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCommunity,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: _communities.map((c) =>
                DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) =>
                setState(() => _selectedCommunity = val!),
            ),
          ],
        ),
      ),
    );
  }
}