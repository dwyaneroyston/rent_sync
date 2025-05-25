import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_sync/auth/login_page.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Content with Padding
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    "HELLO , WELCOME TO RENT SYNC",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Choose your role to continue",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 50),

                  // Tenant Button
                  _buildRoleCard(
                    iconPath: "assets/images/house.png",
                    label: "Tenant",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => LoginPage(role: 'tenant')),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildRoleCard(
                    iconPath: "assets/images/handshake.png",
                    label: "Landlord",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => LoginPage(role: 'landlord')),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            Expanded(
              child: Image.asset(
                "assets/images/image 1.png",
                width: double.infinity,
                fit: BoxFit.fill,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Role Card Builder
  Widget _buildRoleCard({
    required String iconPath,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Image.asset(iconPath, width: 32, height: 32),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
