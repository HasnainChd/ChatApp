import 'dart:io';

import 'package:chat_app/Services/auth_service.dart';
import 'package:chat_app/Services/database_service.dart';
import 'package:chat_app/Services/media_service.dart';
import 'package:chat_app/Services/storage_service.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/user_profile.dart';
import 'package:chat_app/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../models/chat.dart';

class ChatPage extends StatefulWidget {
  final UserProfile chatUser;

  const ChatPage({super.key, required this.chatUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GetIt getIt = GetIt.instance;

  late AuthService _authService;
  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late StorageService _storageService;

  ChatUser? currentUser, otherUser;

  @override
  void initState() {
    super.initState();
    _authService = getIt.get<AuthService>();
    _databaseService = getIt.get<DatabaseService>();
    _mediaService = getIt.get<MediaService>();
    _storageService = getIt.get<StorageService>();

    currentUser = ChatUser(
      id: _authService.user!.uid,
      firstName: _authService.user!.displayName,
    );

    otherUser = ChatUser(
      id: widget.chatUser.uid!,
      firstName: widget.chatUser.name,
      profileImage: widget.chatUser.pfpURL,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatUser.name!),
      ),
      body: buildUi(),
    );
  }

  Widget buildUi() {
    return StreamBuilder(
        stream: _databaseService.getChatData(currentUser!.id, otherUser!.id),
        builder: (context, snapshots) {
          Chat? chat = snapshots.data?.data();
          List<ChatMessage> messages = [];
          if (chat != null && chat.messages != null) {
            messages = generateChatMessagesList(chat.messages!);
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
            child: DashChat(
              inputOptions: InputOptions(
                trailing: [mediaButton()],
                alwaysShowSend: true,
              ),
              messageOptions: const MessageOptions(
                currentUserContainerColor: Colors.black,
                showTime: true,
                showOtherUsersAvatar: true,
              ),
              messages: messages,
              currentUser: currentUser!,
              onSend: sendMessage,
            ),
          );
        });
  }

  //function to send message
  Future<void> sendMessage(ChatMessage chatMessage) async {
    if (chatMessage.medias != null && chatMessage.medias!.isNotEmpty) {
      final media = chatMessage.medias!.first;
      if (media.type == MediaType.image) {
        Message message = Message(
          senderID: chatMessage.user.id,
          content: media.url, // Assuming the media is an image URL.
          messageType: MessageType.Image,
          sentAt: Timestamp.fromDate(chatMessage.createdAt),
        );
        await _databaseService.sendChatMessage(
          currentUser!.id,
          otherUser!.id,
          message,
        );
      } else {
        // Handle other media types here.
      }
    } else {
      // Handle text message
      Message message = Message(
        senderID: currentUser!.id,
        content: chatMessage.text,
        messageType: MessageType.Text,
        sentAt: Timestamp.fromDate(chatMessage.createdAt),
      );
      await _databaseService.sendChatMessage(
        currentUser!.id,
        otherUser!.id,
        message,
      );
    }
  }

  //generate chatList of Messages function
  List<ChatMessage> generateChatMessagesList(List<Message> messages) {
    List<ChatMessage> chatMessages = messages.map((m) {
      if (m.messageType == MessageType.Image) {
        return ChatMessage(
          text: '',
          user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
          createdAt: m.sentAt!.toDate(),
          medias: [
            ChatMedia(url: m.content!, fileName: '', type: MediaType.image),
          ],
        );
      } else {
        return ChatMessage(
          text: m.content!,
          user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
          createdAt: m.sentAt!.toDate(),
        );
      }
    }).toList();
    chatMessages.sort((a, b) {
      return b.createdAt.compareTo(a.createdAt);
    });
    return chatMessages;
  }

  //media button to upload
  Widget mediaButton() {
    return IconButton(
        onPressed: () async {
          File? file = await _mediaService.pickImage();
          if (file != null) {
            String chatId = generateChatId(
              uid1: currentUser!.id,
              uid2: otherUser!.id,
            );
            String? downloadUrl = await _storageService.uploadImageToChat(
              file: file,
              chatId: chatId,
            );
            if (downloadUrl != null) {
              ChatMessage chatMessage = ChatMessage(
                text: '',
                user: currentUser!,
                createdAt: DateTime.now(),
                medias: [
                  ChatMedia(
                      url: downloadUrl, fileName: '', type: MediaType.image),
                ],
              );
              sendMessage(chatMessage);
            }
          }
        },
        icon: Icon(
          Icons.image,
          color: Theme.of(context).colorScheme.primary,
        ));
  }
}
