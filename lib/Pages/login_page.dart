import 'package:chat_app/Constant/constant.dart';
import 'package:chat_app/Services/alert_service.dart';
import 'package:chat_app/Services/auth_service.dart';
import 'package:chat_app/Services/navigation_service.dart';
import 'package:chat_app/Widgets/custom_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GlobalKey<FormState> loginFormKey = GlobalKey();
  String? email, password;
  bool isLoading = false;

  final GetIt getIt = GetIt.instance;

  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _navigationService = getIt.get<NavigationService>();
    _authService = getIt.get<AuthService>();
    _alertService = getIt.get<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: buildUI(),
    );
  }

  Widget buildUI() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: headerText(),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isLoading) loginForm(),
                    if (!isLoading) const SizedBox(height: 20),
                    if (!isLoading) loginButton(),
                    const SizedBox(height: 10),
                    if (!isLoading) createAccountLink(),
                    if (isLoading)
                      const Center(
                        child: CircularProgressIndicator(),
                      )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget headerText() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hi, Welcome back ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          Text('Login to Continue',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Colors.grey,
              ))
        ],
      ),
    );
  }

  Widget loginForm() {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.30, // Adjust height
      child: Form(
        key: loginFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomTextfield(
              hintText: 'Email',
              onSaved: (value) {
                setState(() {
                  email = value;
                });
              },
              validationRegex: emailValidationRegex,
              height: MediaQuery.sizeOf(context).height * .1,
            ),
            CustomTextfield(
              hintText: 'Password',
              onSaved: (value) {
                setState(() {
                  password = value;
                });
              },
              validationRegex: passwordValidationRegex,
              height: MediaQuery.sizeOf(context).height * .1,
            ),
          ],
        ),
      ),
    );
  }

  Widget loginButton() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: ElevatedButton(
        onPressed: () async {
          if (loginFormKey.currentState?.validate() ?? false) {
            setState(() {
              isLoading = true;
            });
            //print('congratulations');
            loginFormKey.currentState?.save();
            final bool result = await _authService.login(email!, password!);

            if (result) {
              _navigationService.pushReplacementNamed('/home');
              _alertService.showToast(
                  text: 'login successful', icon: Icons.check);
            } else {
              _alertService.showToast(
                text: 'failed to login, please try again',
                icon: Icons.cancel,
              );
              setState(() {
                isLoading = false;
              });
            }
          }
        },
        //color: Theme.of(context).colorScheme.primary,
        style: ElevatedButton.styleFrom(
          shape: const RoundedRectangleBorder(side: BorderSide(width: 0.5)),
          backgroundColor: Colors.grey.shade100,
          foregroundColor: Colors.black,
        ),
        child: const Text(
          'Login',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget createAccountLink() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Don\'t have an account?',
            style: TextStyle(fontSize: 16),
          ),
          TextButton(
              onPressed: () {
                _navigationService.pushNamed('/register');
              },
              child: const Text(
                'Signup',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )),
        ],
      ),
    );
  }
}
