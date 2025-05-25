import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RequestCard extends StatelessWidget {
  final String title;
  final String date;
  final String status;

  const RequestCard({
    required this.title,
    required this.date,
    required this.status,
    super.key,
  });

  Color getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color.fromARGB(255, 50, 130, 244);
      case 'In Progress':
        return Colors.yellow;
      case 'Completed':
        return Color(0xff40FF00);
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Card(
        color: Colors.white,
        elevation: 6,
        
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          
        ),
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.normal),
                  ),
                  SizedBox(height: 6),
                  Text(date, style: GoogleFonts.inter(fontSize: 14)),
                ],
              ),
              // Right status badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: getStatusColor(status),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.normal,fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
