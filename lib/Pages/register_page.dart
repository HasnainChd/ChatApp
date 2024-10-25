import 'dart:io';

import 'package:chat_app/Constant/constant.dart';
import 'package:chat_app/Services/alert_service.dart';
import 'package:chat_app/Services/database_service.dart';
import 'package:chat_app/Services/media_service.dart';
import 'package:chat_app/Services/navigation_service.dart';
import 'package:chat_app/Services/storage_service.dart';
import 'package:chat_app/Widgets/custom_textfield.dart';
import 'package:chat_app/models/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../Services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  File? selectedImage;

  final GlobalKey<FormState> registerFormKey = GlobalKey();

  String? name, email, password;
  bool isLoading = false;

  final GetIt getIt = GetIt.instance;

  late NavigationService _navigationService;
  late MediaService _mediaService;
  late AuthService _authService;
  late AlertService _alertService;
  late StorageService _storageService;
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _navigationService = getIt.get<NavigationService>();
    _mediaService = getIt.get<MediaService>();
    _authService = getIt.get<AuthService>();
    _alertService = getIt.get<AlertService>();
    _storageService = getIt.get<StorageService>();
    _databaseService = getIt.get<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildUI(),
    );
  }

  Widget buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              headerText(),
              if (!isLoading) registerForm(),
              if (!isLoading) loginAccountLink(),
              if (isLoading) const Center(child: CircularProgressIndicator())
            ],
          ),
        ),
      ),
    );
  }

  Widget headerText() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Let\'s get going',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          Text(
            'Register Using the form below',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          )
        ],
      ),
    );
  }

  Widget registerForm() {
    return Container(
      height: MediaQuery.sizeOf(context).height * .60,
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height * 0.05,
      ),
      child: Form(
        key: registerFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            profilePicture(),
            CustomTextfield(
              hintText: 'Name',
              onSaved: (value) {
                setState(() {
                  name = value;
                });
              },
              validationRegex: nameValidationRegex,
              height: MediaQuery.sizeOf(context).height * 0.1,
            ),
            CustomTextfield(
              hintText: 'Email',
              onSaved: (value) {
                setState(() {
                  email = value;
                });
              },
              validationRegex: emailValidationRegex,
              height: MediaQuery.sizeOf(context).height * 0.1,
            ),
            CustomTextfield(
              hintText: 'Password',
              onSaved: (value) {
                password = value;
              },
              validationRegex: passwordValidationRegex,
              height: MediaQuery.sizeOf(context).height * 0.1,
            ),
            registerButton(),
          ],
        ),
      ),
    );
  }

  Widget profilePicture() {
    return Container(
        margin: EdgeInsets.symmetric(
          vertical: MediaQuery.sizeOf(context).height * 0.02,
        ),
        child: InkWell(
          onTap: () async {
            File? file = await _mediaService.pickImage();
            if (file != null) {
              setState(() {
                selectedImage = file;
              });
            }
          },
          child: CircleAvatar(
            radius: MediaQuery.of(context).size.width * 0.15,
            backgroundImage: selectedImage != null
                ? FileImage(selectedImage!)
                : const NetworkImage(personIcon),
          ),
        ));
  }

  Widget registerButton() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: ElevatedButton(
        onPressed: () async {
          setState(() {
            isLoading = true;
          });
          try {
            if ((registerFormKey.currentState?.validate() ?? false) &&
                selectedImage != null) {
              registerFormKey.currentState!.save();

              bool result = await _authService.signUp(email!, password!);

              if (result) {
                String? profileUrl = await _storageService.uploadProfile(
                  file: selectedImage!,
                  uid: _authService.user!.uid,
                );
                if (profileUrl != null) {
                  await _databaseService.createUserProfile(
                    userProfile: UserProfile(
                      uid: _authService.user!.uid,
                      name: name,
                      pfpURL: profileUrl,
                    ),
                  );
                  _alertService.showToast(
                    text: 'User registered successfully',
                    icon: Icons.check,
                  );
                  _navigationService.pushReplacementNamed('/home');
                } else {
                  _alertService.showToast(
                      text: 'Unable to upload profile picture');
                }
              } else {
                throw Exception('unable to register User');
              }
            }
          } on FirebaseAuthException catch (e) {
            _alertService.showToast(
              text: e.toString(),
              icon: Icons.error,
            );
            _alertService.showToast(
              text: 'registration  failed. Please try again.',
              icon: Icons.cancel,
            );
          }
          setState(() {
            isLoading = false;
          });
        },
        style: ElevatedButton.styleFrom(
          shape: const RoundedRectangleBorder(side: BorderSide(width: 0.5)),
          backgroundColor: Colors.grey.shade100,
          foregroundColor: Colors.black,
        ),
        child: const Text(
          'Register',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget loginAccountLink() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Already have an account?'),
        TextButton(
          onPressed: () {
            _navigationService.goBack();
          },
          child: const Text(
            'Login',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        )
      ],
    );
  }
}
