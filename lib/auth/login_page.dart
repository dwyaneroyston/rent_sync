import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_sync/roles/landlord/landlord_home_screen.dart';
import 'package:rent_sync/roles/tenant/tenant_home_screen.dart';
import 'package:rent_sync/widgets/custom_button.dart';
import 'package:rent_sync/widgets/custom_text_field.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  final String role; // Accepts 'tenant' or 'landlord'

  const LoginPage({super.key, required this.role});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _login() async {
    try {
      // Authenticate
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // Get role from Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User data not found")),
        );
        return;
      }

      String storedRole = userDoc.get('role');

      if (storedRole != widget.role) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You're trying to log in as the wrong role.")),
        );
        return;
      }

      // Navigate to role-based home
      if (storedRole == 'tenant') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TenantHomeScreen()),
        );
      } else if (storedRole == 'landlord') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) =>  LandlordHomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Login failed")),
      );
    }
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(
builder: (context) => SignupPage(role: widget.role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Welcome back! 👋",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 30),
              CustomTextField(
                hintText: "Email",
                controller: emailController,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: "Password",
                controller: passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Forgot password?",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 30),
              CustomButton(
                text: "Login as ${widget.role.capitalize()}",
                onPressed: _login,
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don’t have an account ? "),
                  GestureDetector(
                    onTap: _navigateToSignUp,
                    child: const Text(
                      "Sign up",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

