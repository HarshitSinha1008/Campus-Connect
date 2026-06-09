import 'package:flutter/material.dart';
import 'package:campus_connect/models/community_model.dart';
import 'community_detail_screen.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = appcommunities
        .where((c) => c.name.toLowerCase().contains(_search.toLowerCase()))
        .toList();
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            onChanged:(val) => setState(() => _search = val),
            decoration: InputDecoration(
              hintText: 'Search communities...',
              hintStyle: const TextStyle(fontSize: 13),
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius:BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          )
        ),

        // Community list
        Expanded(
          child: ListView.separated(
            itemCount: filtered.length,
            separatorBuilder:(context, index) => const Divider(height: 1, thickness: 0.5),
            itemBuilder:(context, index) {
              final community = filtered[index];
              return ListTile(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CommunityDetailScreen(
                      community: community,
                    ),
                  ),
                ),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: community.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    community.icon,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                title: Text(community.name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                subtitle: Text(community.description, 
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                trailing: Text(
                  '${community.membersCount} members',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade400,
                  ),
                ),
              );
            },
          ),
        ),
      ]
    );
  }
}