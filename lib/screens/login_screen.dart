import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:clue/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final supabase = Supabase.instance.client;

  Future<void> _googleSignIn() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'clue://oauth/callback',
      );
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google login failed: $error')));
    }
  }

  Future<void> _appleSignIn() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'clue://oauth/callback',
      );
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Apple login failed: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Spacer(flex: 2),
              Text(
                'CLUE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'AI와 함께 만드는 캐릭터 이야기',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              ),
              const Spacer(flex: 3),
              ElevatedButton.icon(
                onPressed: _googleSignIn,
                icon: const Icon(
                  Icons.g_mobiledata,
                ), // Replace with a proper Google icon if you have one
                label: const Text('Google로 계속하기'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _appleSignIn,
                icon: const Icon(Icons.apple),
                label: const Text('Apple로 계속하기'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const Spacer(flex: 1),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
                child: const Text(
                  '로그인 없이 둘러보기',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
