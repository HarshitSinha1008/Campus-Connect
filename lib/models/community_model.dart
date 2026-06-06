import 'package:flutter/material.dart';

class CommunityModel {
  final String id;
  final String name;
  final String description;
  final Color color;
  final IconData icon;
  final int membersCount;

  CommunityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.icon,
    required this.membersCount,
  });
}

// Static list - no Firestore needed for communities
final List<CommunityModel> appcommunities = [
  CommunityModel(
    id: 'CSE',
    name: 'Computer Science (CSE)',
    description: 'Talk about coding, projects, placements and more.',
    color: Colors.indigo,
    icon: Icons.code,
    membersCount: 523,
  ),
  CommunityModel(
    id: 'ECE',
    name: 'Electronics and Communication Engineering (ECE)',
    description: 'Discuss circuits, embedded systems and communication technologies.',
    color: Colors.cyan.shade700,
    icon: Icons.code,
    membersCount: 523,
  ),
  CommunityModel(
    id: 'EEE',
    name: 'Electrical and Electronics Engineering (EEE)',
    description: 'Talk about circuits, power systems and more.',
    color: const Color.fromARGB(255, 232, 240, 82),
    icon: Icons.code,
    membersCount: 523,
  ),
  CommunityModel(
    id: 'ME',
    name: 'Mechanical Engineering (ME)',
    description: 'Everything about machines, design and manufacturing.',
    color: Colors.purple.shade600,
    icon: Icons.code,
    membersCount: 523,
  ),
  CommunityModel(
    id: 'MBA',
    name: 'Master of Business Administration (MBA)',
    description: 'Discuss business strategies, management and leadership.',
    color: Colors.green.shade600,
    icon: Icons.code,
    membersCount: 523,
  ),
  CommunityModel(
    id: 'Sports',
    name: 'Sports',
    description: 'Sports updates, games and physical activities.',
    color: Colors.orange.shade600,
    icon: Icons.sports,
    membersCount: 523,
  ),
  CommunityModel(
    id: 'Events',
    name: 'Events',
    description: 'Upcoming events and announcements.',
    color: Colors.pink.shade600,
    icon: Icons.event,
    membersCount: 523,
  ),
  CommunityModel(
    id: 'General',
    name: 'General',
    description: 'General discussions.',
    color: Colors.amber.shade700,
    icon: Icons.chat,
    membersCount: 523,
  ),
];