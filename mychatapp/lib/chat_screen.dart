import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mychatapp/chat_provider.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String? chatId;
  final String receiverId;

  const ChatScreen({super.key, required this.chatId, required this.receiverId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  User? loggedInUser;
  String? chatId;

  @override
  void initState() {
    super.initState();
    chatId = widget.chatId;
    getCurrentUser();
  }

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        loggedInUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final TextEditingController textController = TextEditingController();
    return FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('users').doc(widget.receiverId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final recevierData = snapshot.data!.data() as Map<String, dynamic>;
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                title: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(recevierData['imageURL']),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(recevierData['name']),
                  ],
                ),
              ),
              body: Column(
                children: [
                  Expanded(
                      child: chatId != null && chatId!.isEmpty
                          ? MessagesStream(chatId: chatId!)
                          : const Center(
                              child: Text("No messages yet\n"),
                            )),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    child: Row(
                      children: [
                        Expanded(
                            child: TextFormField(
                          controller: textController,
                          decoration: const InputDecoration(
                              hintText: "Enter your message here",
                              border: InputBorder.none),
                        )),
                        IconButton(
                            onPressed: () async {
                              if (textController.text.isNotEmpty) {
                                if (chatId == null || chatId!.isEmpty) {
                                  chatId = await chatProvider
                                      .createChatRoom(widget.receiverId);
                                }
                                if (chatId != null) {
                                  chatProvider.sendMessage(chatId!,
                                      textController.text, widget.receiverId);
                                  textController.clear();
                                }
                              }
                            },
                            icon: const Icon(
                              Icons.send,
                              color: Colors.blue,
                            ))
                      ],
                    ),
                  )
                ],
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
  }
}

class MessagesStream extends StatelessWidget {
  final String chatId;

  const MessagesStream({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final messages = snapshot.data!.docs;
        List<MessageBubble> messageWidgets = [];
        for (var message in messages) {
          final messageData = message.data() as Map<String, dynamic>;
          final messagetext = messageData['messageBody'];
          final messageSender = messageData['senderId'];
          final timestamp =
              messageData['timestamp'] ?? FieldValue.serverTimestamp();
          final currentUser = FirebaseAuth.instance.currentUser!.uid;
          final messafeWidget = MessageBubble(
            sender: messageSender,
            text: messagetext,
            isMe: currentUser == messageSender,
            timestamp: timestamp,
          );

          messageWidgets.add(messafeWidget);
        }
        return ListView(
          reverse: true,
          children: messageWidgets,
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;
  final dynamic timestamp;

  const MessageBubble(
      {super.key,
      required this.sender,
      required this.text,
      required this.isMe,
      this.timestamp});

  @override
  Widget build(BuildContext context) {
    final messageTime =
        (timestamp is Timestamp) ? timestamp.toDate() : DateTime.now();
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(color: Colors.black, blurRadius: 4, spreadRadius: 2)
              ],
              borderRadius: isMe
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15))
                  : const BorderRadius.only(
                      topRight: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15)),
              color: isMe ? const Color(0xFF3876FD) : Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                        fontSize: 15),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "${messageTime.hour}:${messageTime.minute}",
                    style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
