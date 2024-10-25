import 'package:chat_app/Services/auth_service.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/user_profile.dart';
import 'package:chat_app/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../models/chat.dart';

class DatabaseService {
  final GetIt getIt = GetIt.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  late AuthService _authService;
  CollectionReference? _userCollection;
  CollectionReference? _chatCollection;

  DatabaseService() {
    _setupFirebaseCollection();
    _authService = getIt.get<AuthService>();
  }

  //setup collections of user and also chat
  _setupFirebaseCollection() {
    _userCollection =
        _firebaseFirestore.collection('users').withConverter<UserProfile>(
              fromFirestore: (snapshots, _) =>
                  UserProfile.fromJson(snapshots.data()!),
              toFirestore: (userProfile, _) => userProfile.toJson(),
            );
    _chatCollection =
        _firebaseFirestore.collection('chats').withConverter<Chat>(
              fromFirestore: (snapshots, _) => Chat.fromJson(snapshots.data()!),
              toFirestore: (chat, _) => chat.toJson(),
            );
  }

  // create user profile function
  Future<void> createUserProfile({required UserProfile userProfile}) async {
    await _userCollection?.doc(userProfile.uid).set(userProfile);
  }

  //function that get all users profile
  Stream<QuerySnapshot<UserProfile>> getUserProfiles() {
    return _userCollection
        ?.where('uid', isNotEqualTo: _authService.user!.uid)
        .snapshots() as Stream<QuerySnapshot<UserProfile>>;
  }

  //function to check that if there is chat already present or not
  Future<bool> checkChatExists(String uid1, String uid2) async {
    String chatId = generateChatId(uid1: uid1, uid2: uid2);

    final result = (await _chatCollection?.doc(chatId).get());
    if (result != null) {
      return result.exists;
    } else {
      return false;
    }
  }

  // if chat not exist create a chat between users
  Future<void> createNewChat(String uid1, String uid2) async {
    String chatID = generateChatId(uid1: uid1, uid2: uid2);
    final docRef = _chatCollection!.doc(chatID);

    final chat = Chat(id: chatID, participants: [uid1, uid2], messages: []);
    await docRef.set(chat);
  }

  //function for sending chatMessage
  Future<void> sendChatMessage(String uid1, String uid2, Message message) async {
    String chatID = generateChatId(uid1: uid1, uid2: uid2);
    final docRef = _chatCollection!.doc(chatID);

    final chatSnap = await docRef.get();
    if (!chatSnap.exists) {
      await createNewChat(uid1, uid2);  // Ensure the chat is created first
    }

    await docRef.update({
      'messages': FieldValue.arrayUnion([message.toJson()])
    });
  }


  //display chats on screen
  Stream<DocumentSnapshot<Chat>> getChatData(String uid1, String uid2) {
    String chatID = generateChatId(uid1: uid1, uid2: uid2);
    return _chatCollection?.doc(chatID).snapshots()
        as Stream<DocumentSnapshot<Chat>>;
  }
}
