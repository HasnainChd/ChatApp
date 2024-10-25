import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  StorageService() {}

  Future<String?> uploadProfile(
      {required File file, required String uid}) async {
    Reference fileRef = _firebaseStorage
        .ref('users/profiles')
        .child('$uid${p.extension(file.path)}');

    UploadTask task = fileRef.putFile(file);
    return task.then((p) {
      if (p.state == TaskState.success) {
        return fileRef.getDownloadURL();
      }
      return null;
    });
  }

  Future<String?> uploadImageToChat(
      {required File file, required String chatId}) async {
    Reference fileRef = _firebaseStorage.ref('chat/$chatId').child(
          '${DateTime.now().toIso8601String()} ${p.extension(file.path)}',
        );
    UploadTask task = fileRef.putFile(file);

    return task.then((p) {
      if (p.state == TaskState.success) {
        return fileRef.getDownloadURL();
      }
      return null;
    });
  }
}
