// lib/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final VoidCallback? onMenuPressed;

  const CustomAppBar({
    super.key,
    this.actions,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: onMenuPressed ?? () {},
        icon: Icon(Icons.arrow_back, size: 30),
      ),
      title: Text(
        "RENTSYNC",
        style: GoogleFonts.cabin(fontWeight: FontWeight.w600, fontSize: 18),
      ),
      centerTitle: true,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
