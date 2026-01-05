import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final myUid = FirebaseAuth.instance.currentUser!.uid;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 14),

            // 🖋️ Header
            const Center(
              child: Text(
                "Messages",
                style: TextStyle(
                  fontSize: 26,
                  fontFamily: 'Pacifico',
                  color: Color(0xFF5A3A8C),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 🔍 Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (v) {
                  setState(() => searchQuery = v.toLowerCase());
                },
                decoration: InputDecoration(
                  hintText: "Search chats",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 💬 Chats
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .where('participants', arrayContains: myUid)
                    .orderBy('lastMessageAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  final chats = snapshot.data!.docs.where((doc) {
                    final data =
                        doc.data() as Map<String, dynamic>;

                    final names =
                        Map<String, dynamic>.from(data['participantNames']);
                    final otherName = names.values
                        .firstWhere((_) => true)
                        .toString()
                        .toLowerCase();

                    final itemTitle =
                        (data['itemTitle'] ?? '').toString().toLowerCase();

                    final lastMessage =
                        (data['lastMessage'] ?? '').toString().toLowerCase();

                    return otherName.contains(searchQuery) ||
                        itemTitle.contains(searchQuery) ||
                        lastMessage.contains(searchQuery);
                  }).toList();

                  if (chats.isEmpty) {
                    return const Center(
                      child: Text("No messages found"),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final doc = chats[index];
                      final chat =
                          doc.data() as Map<String, dynamic>;

                      final participants =
                          List<String>.from(chat['participants']);
                      final otherUid =
                          participants.firstWhere((id) => id != myUid);

                      final names =
                          Map<String, dynamic>.from(chat['participantNames']);
                      final otherName = names[otherUid] ?? '';

                      final unreadBy =
                          List<String>.from(chat['unreadBy'] ?? []);
                      final isUnread = unreadBy.contains(myUid);

                      final lastSender = chat['lastSenderId'];
                      final lastMessage = chat['lastMessage'] ?? '';

                      final preview = lastSender == myUid
                          ? "You: $lastMessage"
                          : "$otherName: $lastMessage";

                      final itemTitle =
                          (chat['itemTitle'] ?? '').toString();

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                chatId: doc.id,
                                peerName: otherName,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isUnread
                                ? const Color(0xFFEDE6FF)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 24,
                                backgroundImage: AssetImage(
                                    'assets/profile_placeholder.png'),
                              ),
                              const SizedBox(width: 12),

                              // 👤 Name + preview
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            otherName,
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: isUnread
                                                  ? FontWeight.bold
                                                  : FontWeight.w600,
                                            ),
                                          ),
                                        ),

                                        // 🔴 Unread bubble
                                        if (isUnread)
                                          Container(
                                            margin:
                                                const EdgeInsets.only(
                                                    left: 6),
                                            padding:
                                                const EdgeInsets.all(6),
                                            decoration:
                                                const BoxDecoration(
                                              color: Color(0xFF7B2FF7),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Text(
                                              "1",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      preview,
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isUnread
                                            ? Colors.black87
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),

                              // 📦 Item tag
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCEBFF),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: Text(
                                  itemTitle.length > 18
                                      ? "${itemTitle.substring(0, 18)}…"
                                      : itemTitle,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF4A7DFF),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
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
