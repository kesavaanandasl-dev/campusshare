import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String ownerName;
  final String itemId;

  const ChatScreen({
    super.key,
    required this.ownerName,
    required this.itemId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  Stream<QuerySnapshot> get messagesStream {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.itemId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF5B55D6),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: messagesStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No messages yet",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final msg = docs[index];
                      final isMe =
                          msg['senderUid'] == currentUid;

                      return _chatBubble(
                        msg['text'],
                        isMe: isMe,
                      );
                    },
                  );
                },
              ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      color: const Color(0xFF5B55D6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 6),
          const CircleAvatar(
            radius: 20,
            backgroundImage:
                AssetImage('assets/profile_placeholder.png'),
          ),
          const SizedBox(width: 10),
          Text(
            widget.ownerName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Set Meetup',
              style: TextStyle(
                color: Color(0xFF5B55D6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= CHAT BUBBLE =================
  Widget _chatBubble(String text, {required bool isMe}) {
    return Align(
      alignment:
          isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          color: isMe ? Colors.white : const Color(0xFF7C78E6),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isMe ? Colors.black87 : Colors.white,
          ),
        ),
      ),
    );
  }

  // ================= INPUT BAR =================
  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _controller,
                decoration:
                    const InputDecoration(border: InputBorder.none),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              height: 46,
              width: 46,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                color: Color(0xFF5B55D6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser!;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.itemId)
        .collection('messages')
        .add({
      'text': _controller.text.trim(),
      'senderUid': user.uid,
      'senderName': userDoc['name'],
      'timestamp': FieldValue.serverTimestamp(),
    });

    _controller.clear();
  }
}
