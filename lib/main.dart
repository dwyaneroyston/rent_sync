import 'package:flutter/material.dart';
import 'package:rent_sync/auth/signup_page.dart';
import 'package:rent_sync/role_selection_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rent_sync/roles/landlord/landlord_home_screen.dart';
import 'package:rent_sync/roles/tenant/tenant_home_screen.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, 
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black, //
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          brightness: Brightness.light,
        ).copyWith(
          surface: Colors.white,
          primary: Colors.black,
          onPrimary: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: RoleSelectionPage(),
    );
  }
}
