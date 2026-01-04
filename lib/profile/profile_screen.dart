import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F2FB),
      body: Column(
        children: [
          // 🔝 TOP CURVED HEADER
          Stack(
            children: [
              Container(
                height: 260,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF7B2FF7),
                      Color(0xFF9D4EDD),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
              ),

              // Menu icon
              Positioned(
                top: 40,
                left: 16,
                child: Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
              ),

              // Profile content
              Positioned.fill(
                top: 70,
                child: Column(
                  children: [
                    // Profile image
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 42,
                        backgroundImage: const AssetImage(
                          'assets/profile_placeholder.png',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Name
                    Text(
                      user?.email?.split('@')[0] ?? "CampusShare User",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      "CampusShare User",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 📊 STATS (2 COLUMN)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _statCard("Lent", "12"),
                const SizedBox(width: 16),
                _statCard("Borrowed", "5"),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 📋 MENU LIST
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _menuItem(Icons.person_outline, "My Profile"),
                  _menuItem(Icons.message_outlined, "Messages", badge: "7"),
                  _menuItem(Icons.favorite_border, "Favourites"),
                  _menuItem(Icons.location_on_outlined, "Location"),
                  _menuItem(Icons.settings_outlined, "Settings"),

                  const Spacer(),

                  // 🚪 LOGOUT
                  TextButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    icon: const Icon(Icons.logout, color: Colors.grey),
                    label: const Text(
                      "Logout",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔢 STAT CARD
  Widget _statCard(String title, String value) {
    return Expanded(
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7B2FF7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📌 MENU ITEM
  Widget _menuItem(IconData icon, String title, {String? badge}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade700),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          if (badge != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
