import 'package:firebase_core/firebase_core.dart';
    
import 'package:flutter/material.dart';
import 'package:mychatapp/auth_provider.dart';
import 'package:mychatapp/chat_provider.dart';
import 'package:mychatapp/chat_screen.dart';
import 'package:mychatapp/home_screen.dart';
import 'package:mychatapp/login_page.dart';
import 'package:mychatapp/search_screen.dart';
import 'package:mychatapp/signup_screen.dart';
import 'package:mychatapp/firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProviderr()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          "/HomeScreen": (context) => const HomeScreen(),
          "/LoginScreen": (context) => const LoginScreen(),
          "/SignUpScreen": (context) => const SignUpScreen(),
          "/SearchScreen": (context) => const SearchScreen(),
        
        },
        home: const AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProviderr>(
      builder: (context, autherProvider, child) {
        if (autherProvider.isSignedIn) {
          return const HomeScreen();
        } else {
          return  LoginScreen();
        }
      },
    );
  }
}
