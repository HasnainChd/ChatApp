import 'package:chat_app/Pages/home_page.dart';
import 'package:chat_app/Pages/login_page.dart';
import 'package:chat_app/Pages/register_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavigationService {
  late GlobalKey<NavigatorState> _navigatorKey;

  final Map<String, Widget Function(BuildContext)> _routes = {
    '/login': (context) => const LoginPage(),
    '/register':(context)=> const RegisterPage(),
    '/home': (context)=> const HomePage()
  };

  GlobalKey<NavigatorState>? get navigatorKey {
    return _navigatorKey;
  }

  Map<String, Widget Function(BuildContext)> get routes {
    return _routes;
  }

  NavigationService() {
    _navigatorKey = GlobalKey<NavigatorState>();
  }
  //push
  void push(MaterialPageRoute route){
    navigatorKey?.currentState!.push(route);
  }
  //push Named
  void pushNamed(String routeName){
    _navigatorKey.currentState?.pushNamed(routeName);
  }
  //Push replacementNamed
 void pushReplacementNamed(String routeName){
    _navigatorKey.currentState?.pushReplacementNamed(routeName);
 }
 //go-back
void goBack(){
    _navigatorKey.currentState?.pop();
}
}
