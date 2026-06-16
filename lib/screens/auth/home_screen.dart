import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_connect/services/auth_service.dart';
import 'package:campus_connect/screens/feed/feed_screen.dart';
import 'package:campus_connect/screens/createpost/create_post_screen.dart';
import 'login_screen.dart';
import 'package:campus_connect/screens/communities/communities_screen.dart';
import 'package:campus_connect/screens/profile/profile_screen.dart';
import 'package:campus_connect/screens/explorer/explorer_screen.dart';
import 'package:campus_connect/screens/market_place/marketplace_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Defined outside build — never recreated
  final List<Widget> _screens = const [
    FeedScreen(),
    CommunitiesScreen(),
    ExplorerScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users').doc(uid).get(),
              builder: (context, snapshot) {
                final name = snapshot.hasData
                    ? (snapshot.data!.data()
                        as Map<String, dynamic>)['name'] ?? ''
                    : '';
                return CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.indigo,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white, fontSize: 12)),
                );
              },
            ),
            const SizedBox(width: 10),
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
                children: [
                  TextSpan(text: 'Campus'),
                  TextSpan(text: 'Connect',
                    style: TextStyle(color: Colors.indigo)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
              color: Colors.black),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20)),
                ),
                builder: (_) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Notifications',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      Icon(Icons.notifications_none,
                        size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('No notifications yet',
                        style: TextStyle(
                          color: Colors.grey.shade500)),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await AuthService().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),

      // ← IndexedStack keeps all screens alive
      body: Stack(
        children: [IndexedStack(
          index: _currentIndex,
      children: _screens,
    ),

    // Marketplace button above bottom nav
    Positioned(
      bottom: 8,
      right: 16,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const MarketplaceScreen()),
        ),
        icon: const Icon(Icons.storefront_outlined, size: 16),
        label: const Text('Market',
          style: TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.indigo,
          elevation: 4,
          shadowColor: Colors.black26,
          side: const BorderSide(color: Colors.indigo),
          padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        ),
      ),
    ),
  ],
),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CreatePostScreen()),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home,
                color: _currentIndex == 0
                    ? Colors.indigo : Colors.grey),
              onPressed: () => setState(() => _currentIndex = 0),
            ),
            IconButton(
              icon: Icon(Icons.groups,
                color: _currentIndex == 1
                    ? Colors.indigo : Colors.grey),
              onPressed: () => setState(() => _currentIndex = 1),
            ),
            const SizedBox(width: 40),
            IconButton(
              icon: Icon(Icons.explore,
                color: _currentIndex == 2
                    ? Colors.indigo : Colors.grey),
              onPressed: () => setState(() => _currentIndex = 2),
            ),
            IconButton(
              icon: Icon(Icons.person,
                color: _currentIndex == 3
                    ? Colors.indigo : Colors.grey),
              onPressed: () => setState(() => _currentIndex = 3),
            ),
          ],
        ),
      ),
    );
  }
}