// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_sync/roles/tenant/tenant_profile_page.dart';
// import 'package:rent_sync/roles/tenant/home_page.dart'; // Uncomment and add your HomePage

class SideMenu extends StatefulWidget {
  final String userId;
  final String role;

  const SideMenu({super.key, required this.userId, required this.role});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  String? userName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      if (doc.exists && doc.data()!.containsKey('name')) {
        setState(() {
          userName = doc['name'];
          isLoading = false;
        });
      } else {
        setState(() {
          userName = "Unknown";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        userName = "Error";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/images/naomi_scott.jpeg'),
                  radius: 50,
                ),
                const SizedBox(height: 10),
                Text(
                  isLoading ? 'Loading...' : (userName ?? "Unknown"),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.role[0].toUpperCase() + widget.role.substring(1), // Capitalize role
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          const Divider(),
          const SizedBox(height: 50),

          // Home - Working navigation
          SideMenuItem(
            icon: Icons.home,
            title: 'Home',
            selected: false,
            onTap: () {
              Navigator.pop(context);
              // Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage()));
            },
          ),

          // Messages - no navigation
          const SideMenuItem(
            icon: Icons.message,
            title: 'Messages',
            selected: false,
          ),

          // Notifications - no navigation
          const SideMenuItem(
            icon: Icons.notifications,
            title: 'Notifications',
            selected: false,
          ),

          // Profile - Working navigation
          SideMenuItem(
            icon: Icons.person,
            title: 'Profile',
            selected: false,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),

          const Spacer(),
          const Divider(),

          // Logout - no navigation
          const SideMenuItem(
            icon: Icons.logout,
            title: 'Logout',
            selected: false,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class SideMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback? onTap;

  const SideMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: selected ? Colors.white : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(title),
        onTap: onTap,
      ),
    );
  }
}
