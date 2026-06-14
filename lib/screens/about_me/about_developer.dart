import 'package:flutter/material.dart';

class AboutDeveloper extends StatelessWidget {
  const AboutDeveloper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('About Developer'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top indigo banner with avatar
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width:90, height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    child: const Center(
                      child: Text('H',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold
                        )),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Name
                  const Text('Harshit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold
                    )),
                  const SizedBox(height: 4),

                  // Title
                  Text('Flutter Developer',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14,
                    )),
                  
                  const SizedBox(height: 4),

                  // College
                  Text('B.Tech EEE • 2025',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    )),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // About this app section
            _SectionCard(
              icon: Icons.info_outline,
              title: 'About CampusConnect',
              child: const Text(
                'CampusConnect is a college social community app that allows student to connect, share updates, join communities, and stay updated with campus life - all in one place.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: Colors.black87
                ),
              ),
            ),

            // Tech stack section
            _SectionCard(
              icon: Icons.code,
              title: 'Built With',
              child: Column(
                children: [
                  _TechRow(icon: Icons.flutter_dash,
                    color: Colors.blue,
                    name: 'Flutter',
                    detail: 'UI Framework'),
                  _TechRow(icon: Icons.local_fire_department,
                    color: Colors.orange,
                    name: 'Firebase Auth',
                    detail: 'Authentication'),
                  _TechRow(icon: Icons.storage,
                    color: Colors.amber,
                    name: 'Cloud Firestore',
                    detail: 'Real-time Database'),
                  _TechRow(icon: Icons.folder,
                    color: Colors.green,
                    name: 'Firebase Storage',
                    detail: 'Media Storage'),
                ],
              ),
            ),

            // Feature Section
            _SectionCard(
              icon: Icons.star_outline,
              title: 'Features',
              child: Column(
                children: [
                  _FeatureRow('Real-time post feed with likes'),
                  _FeatureRow('College communities by branch'),
                  _FeatureRow('User profiles with photo upload'),
                  _FeatureRow('Post across different communities'),
                  _FeatureRow('Search and explore posts'),
                  _FeatureRow('Join & leave communities'),
                ],
              ),
            ),

            // Contact / links section
            _SectionCard(
              icon: Icons.link,
              title: 'Connect',
              child: Column(
                children: [
                  _LinkRow(
                    icon: Icons.code,
                    color: Colors.black,
                    label: 'GitHub',
                    value: 'https://github.com/HarshitSinha1008',
                  ),
                  _LinkRow(
                    icon: Icons.email_outlined,
                    color: Colors.red,
                    label: 'Email',
                    value: 'harshitsinha55@gmail.com',
                  ),
                  _LinkRow(
                    icon: Icons.link,
                    color: Colors.blue,
                    label: 'linedin',
                    value: 'www.linkedin.com/in/harshit-ranjan-sinha-b0034b32b',
                  ),
                ],
              ),
            ),

            // Version
            const SizedBox(height: 8),
            Text('CampusConnect v1.0.0',
              style: TextStyle(
                fontSize: 12, color: Colors.grey.shade400
              )),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

// ---- Reusable Widgets ---- 

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon, required this.title, required this.child,});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(title,
                  style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: Colors.indigo
                  )),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _TechRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String name;
  final String detail;

  const _TechRow({
    required this.icon,
    required this.color,
    required this.name,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Text(name,
            style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(detail,
            style: TextStyle(
              fontSize: 12, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String text;
  const _FeatureRow(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle,
            size: 16, color: Colors.indigo),
          const SizedBox(width: 10),
          Text(text,
            style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _LinkRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Text(label,
            style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          // ← wrap in Expanded so long text doesn't overflow
          Expanded(
            child: Text(value,
              style: TextStyle(
                fontSize: 12, color: Colors.grey.shade500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}