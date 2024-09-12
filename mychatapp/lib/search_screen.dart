import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mychatapp/chat_provider.dart';
import 'package:mychatapp/chat_screen.dart';

import 'package:provider/provider.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  String searchQuery = '';
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    _searchController.addListener(() {
      handleSearch(_searchController.text.toLowerCase());
    });
  }

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        loggedInUser = user;
      });
    }
  }

  void handleSearch(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Search Users"),
      ),
      body: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: "Search Users ...",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: handleSearch,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: searchQuery.isEmpty ? Stream.empty() : chatProvider.searchUsers(searchQuery),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final users = snapshot.data!.docs;
                print("Number of users found: ${users.length}");
                List<UserTile> userWidgets = [];
                for (var user in users) {
                  final userData = user.data() as Map<String, dynamic>;
                  print(userData);
                  if (userData['uid'] != loggedInUser!.uid) {
                    final userWidget = UserTile(
                      userId: userData['uid'],
                      email: userData['email'],
                      imageURL: userData['imageUrl'],
                      name: userData['name'],
                    );
                    userWidgets.add(userWidget);
                  }
                }
                return ListView(children: userWidgets);
              },
            ),
          ),
        ],
      ),
    );
  }
}


class UserTile extends StatelessWidget {
  final String userId;
  final String name;
  final String email;
  final String imageURL;

  const UserTile(
      {super.key,
      required this.userId,
      required this.name,
      required this.email,
      required this.imageURL});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageURL),
      ),
      title: Text(name),
      subtitle: Text(email),
      onTap: () async {
        final chatId = await chatProvider.getChatRoom(userId) ?? await chatProvider.createChatRoom(userId);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ChatScreen(chatId: chatId, receiverId: userId)));
      },
    );
  }
}
