import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../item/item_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'All';
  final TextEditingController searchController = TextEditingController();

  final categories = ['All', 'Books', 'Stationery', 'Gadgets', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilters(),
            const SizedBox(height: 8),
            Expanded(child: _buildItemList()),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'CampusShare',
            style: TextStyle(
              fontFamily: 'Pacifico', // 👈 cursive handwriting
              fontSize: 26,
              color: Color(0xFF3E2D8F),
            ),
          ),
          GestureDetector(
            onTap: () {
              // later: navigate to profile
            },
            child: const CircleAvatar(
              radius: 20,
              backgroundImage:
                  AssetImage('assets/profile_placeholder.png'),
            ),
          ),
        ],
      ),
    );
  }

  // ================= SEARCH =================
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
            )
          ],
        ),
        child: TextField(
          controller: searchController,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'Search items',
            border: InputBorder.none,
            icon: Icon(Icons.search),
          ),
        ),
      ),
    );
  }

  // ================= FILTERS =================
  Widget _buildFilters() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final active = cat == selectedCategory;

          return GestureDetector(
            onTap: () {
              setState(() => selectedCategory = cat);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF7B2FF7)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: active
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                        )
                      ],
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: active ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

 // ================= ITEM LIST =================
Widget _buildItemList() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('items')
        .snapshots(), // ✅ SAFE STREAM
    builder: (context, snapshot) {
      // 🔴 Firestore error
      if (snapshot.hasError) {
        return const Center(
          child: Text('Failed to load items'),
        );
      }

      // ⏳ Loading
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const Center(
          child: Text(
            'No items found',
            style: TextStyle(color: Colors.grey),
          ),
        );
      }

      final docs = snapshot.data!.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;

        // 🛑 Hide borrowed items
        if (data['status'] == 'borrowed') return false;

        final title =
            (data['title'] ?? '').toString().toLowerCase();
        final category = data['category'] ?? '';

        final matchesSearch = title.contains(
          searchController.text.toLowerCase(),
        );

        final matchesCategory =
            selectedCategory == 'All' ||
            category == selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();

      if (docs.isEmpty) {
        return const Center(
          child: Text(
            'No items found',
            style: TextStyle(color: Colors.grey),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: docs.length,
        itemBuilder: (context, index) {
          final item = docs[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ItemDetailScreen(item: item),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      item['imageUrl'],
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['category'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7B2FF7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
}