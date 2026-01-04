import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'item_tile.dart';
import 'category_filter.dart';
import '../post/post_item_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'All';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 Search + Profile
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                ],
              ),
            ),

            // 👋 Welcome text
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Welcome to\nCampusShare",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B1E5B),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 🏷 Category filter
            CategoryFilter(
              selected: selectedCategory,
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),

            const SizedBox(height: 12),

            // 📦 Firestore items
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('items')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final items = snapshot.data!.docs.where((doc) {
                    final title =
                        doc['title'].toString().toLowerCase();
                    final category = doc['category'];

                    final matchesSearch =
                        title.contains(searchQuery);

                    final matchesCategory =
                        selectedCategory == 'All' ||
                        category == selectedCategory;

                    return matchesSearch && matchesCategory;
                  }).toList();

                  if (items.isEmpty) {
                    return const Center(
                      child: Text('No items found'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return ItemTile(item: items[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

    );
  }
}
