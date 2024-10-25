import 'package:chat_app/Pages/chat_page.dart';
import 'package:chat_app/Services/auth_service.dart';
import 'package:chat_app/Services/database_service.dart';
import 'package:chat_app/Services/navigation_service.dart';
import 'package:chat_app/Widgets/chat_tile.dart';
import 'package:chat_app/models/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GetIt getIt = GetIt.instance;

  late NavigationService _navigationService;
  late AuthService _authService;
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _authService = getIt.get<AuthService>();
    _navigationService = getIt.get<NavigationService>();
    _databaseService = getIt.get<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.grey.shade100,  // Light grey background
        title: const Text(
          'Messages',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: IconButton(
              onPressed: () async {
                bool result = await _authService.logOut();
                if (result) {
                  _navigationService.pushReplacementNamed('/login');
                }
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.black,
                size: 28,
              ),
            ),
          ),
        ],
      ),
      body: buildUI(),
    );
  }

  Widget buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: chatsList(),
      ),
    );
  }

  Widget chatsList() {
    return StreamBuilder(
      stream: _databaseService.getUserProfiles(),
      builder: (context, snapshots) {
        if (snapshots.hasError) {
          return const Center(
            child: Text(
              'Unable to load data',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
          );
        }
        if (snapshots.hasData && snapshots.data != null) {
          final users = snapshots.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              UserProfile user = users[index].data();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ChatTile(
                  userProfile: user,
                  onTap: () async {
                    final chatExists = await _databaseService.checkChatExists(
                      _authService.user!.uid,
                      user.uid!,
                    );
                    if (!chatExists) {
                      await _databaseService.createNewChat(
                        _authService.user!.uid,
                        user.uid!,
                      );
                    }
                    _navigationService.push(
                      MaterialPageRoute(
                        builder: (context) => ChatPage(chatUser: user),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
