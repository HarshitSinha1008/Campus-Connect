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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const FeedScreen(),
    const CommunitiesScreen(),           // Communities — Week 3
    const ExplorerScreen(),
    const ProfileScreen(),           // Profile — Week 3
  ];

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
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
                    style: const TextStyle(color: Colors.white,
                      fontSize: 12)),
                );
              },
            ),
            const SizedBox(width: 10),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 18,
                  fontWeight: FontWeight.bold, color: Colors.black),
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
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreatePostScreen()),
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
          color: _currentIndex == 0 ? Colors.indigo : Colors.grey),
        onPressed: () => setState(() => _currentIndex = 0),
      ),
      const SizedBox(width: 8),
      IconButton(
        icon: Icon(Icons.groups,
          color: _currentIndex == 1 ? Colors.indigo : Colors.grey),
        onPressed: () => setState(() => _currentIndex = 1),
      ),
      const SizedBox(width: 40), // FAB space
      IconButton(
        icon: Icon(Icons.explore,
          color: _currentIndex == 2 ? Colors.indigo : Colors.grey),  
        onPressed: () => setState(() => _currentIndex = 2),
      ),
      IconButton(
        icon: Icon(Icons.person,
          color: _currentIndex == 3 ? Colors.indigo : Colors.grey),
        onPressed: () => setState(() => _currentIndex = 3),
            ),
          ],
        ),
      ),
    );
  }
}