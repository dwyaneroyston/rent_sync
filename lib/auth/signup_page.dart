import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_sync/auth/login_page.dart';
import 'package:rent_sync/widgets/custom_button.dart';
import 'package:rent_sync/widgets/custom_text_field.dart';

class SignupPage extends StatefulWidget {
  final String role; // 'tenant' or 'landlord'
  const SignupPage({super.key, required this.role});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController =
      TextEditingController(); // e.g., "1998-06-01"
  final TextEditingController addressController = TextEditingController();
  final TextEditingController landlordEmailController =
      TextEditingController(); // for tenants only

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      _showSnack("Passwords do not match");
      return;
    }

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      final user = userCredential.user;
      if (user == null) throw Exception("User creation failed");

      final Map<String, dynamic> userData = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'role': widget.role,
        'phone': phoneController.text.trim(),
        'dob': dobController.text.trim(),
        'address': addressController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (widget.role == 'tenant') {
        final landlordQuery = await _firestore
            .collection('users')
            .where('email', isEqualTo: landlordEmailController.text.trim())
            .where('role', isEqualTo: 'landlord')
            .get();

        if (landlordQuery.docs.isEmpty) {
          _showSnack("Landlord not found");
          return;
        }

        final landlordId = landlordQuery.docs.first.id;
        userData['landlordId'] = landlordId;
      }

      await _firestore.collection('users').doc(user.uid).set(userData);
      await user.updateDisplayName(nameController.text.trim());

      _showSnack("Account created successfully");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage(role: widget.role)),
      );
    } catch (e) {
      _showSnack("Sign up failed: ${e.toString()}");
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isTenant = widget.role == 'tenant';
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Text("Sign Up as ${widget.role.capitalize()}"),
              const SizedBox(height: 10),
              Text(
                "Create your RentSync account as ${widget.role.capitalize()}",
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              CustomTextField(hintText: "Name", controller: nameController),
              const SizedBox(height: 20),
              CustomTextField(hintText: "Email", controller: emailController),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: "Password",
                controller: passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: "Confirm Password",
                controller: confirmPasswordController,
                obscureText: true,
              ),
              const SizedBox(height: 20),
              if (isTenant)
                CustomTextField(
                  hintText: "Landlord Email",
                  controller: landlordEmailController,
                ),
              const SizedBox(height: 20),
              CustomTextField(
                  hintText: "Phone Number", controller: phoneController),
              const SizedBox(height: 20),
              CustomTextField(
                  hintText: "Date of Birth (YYYY-MM-DD)",
                  controller: dobController),
              const SizedBox(height: 20),
              CustomTextField(
                  hintText: "Address", controller: addressController),

              const SizedBox(height: 50),

              CustomButton(text: "Sign Up", onPressed: _signUp),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoginPage(role: widget.role),
                        ),
                      );
                    },
                    child: const Text(
                      "Log in",
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

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
