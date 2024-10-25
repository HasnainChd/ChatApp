import 'package:chat_app/Pages/login_page.dart';
import 'package:chat_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Services/auth_service.dart';
import 'Services/navigation_service.dart';

void main() async {
  await setup();
  runApp(MyApp());
}

Future<void> setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupFirebase();
  await registerService();
}

class MyApp extends StatelessWidget {
  final GetIt getIt = GetIt.instance;
  late NavigationService _navigationService;
  late AuthService _authService;

  MyApp({super.key}) {
    _navigationService = getIt.get<NavigationService>();
    _authService = getIt.get<AuthService>();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigationService.navigatorKey,
      theme: ThemeData(textTheme: GoogleFonts.montserratTextTheme(),),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
      routes: _navigationService.routes,
      initialRoute: _authService.user != null ? '/home' : '/login',
    );
  }
}
