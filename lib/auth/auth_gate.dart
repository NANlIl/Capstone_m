import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/main_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 사용자가 로그인하지 않았으면 로그인 화면을 보여줍니다.
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // 사용자가 로그인했으면 메인 화면으로 이동합니다.
        return const MainScreen();
      },
    );
  }
}
