import 'dart:io';

import 'package:image_picker/image_picker.dart';

class MediaService{

   final ImagePicker picker= ImagePicker();

  MediaService(){}

  Future<File?> pickImage()async{
    final XFile? file= await picker.pickImage(source: ImageSource.gallery);
    if(file !=null){
      return File(file.path);
    }else{
      return null;
    }
  }
}