import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class RequestDetailsPage extends StatefulWidget {
  final String requestId;

  const RequestDetailsPage({super.key, required this.requestId});

  @override
  State<RequestDetailsPage> createState() => _RequestDetailsPageState();
}

class _RequestDetailsPageState extends State<RequestDetailsPage> {
  String? userRole;
  DocumentSnapshot? requestSnapshot;
  String? tenantName;
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserRoleAndRequest();
  }

  Future<void> fetchUserRoleAndRequest() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      userRole = userDoc['role'];

      final requestDoc = await FirebaseFirestore.instance.collection('service_requests').doc(widget.requestId).get();
      requestSnapshot = requestDoc;

      final tenantId = requestDoc['tenantId'];
      final tenantDoc = await FirebaseFirestore.instance.collection('users').doc(tenantId).get();
      tenantName = tenantDoc.data()?['name'] ?? 'Unknown';

      setState(() {});
    } catch (e) {
      print("Error fetching request details: $e");
      tenantName = 'Unknown';
      setState(() {});
    }
  }

  void updateStatus(String newStatus) async {
    await FirebaseFirestore.instance.collection('service_requests').doc(widget.requestId).update({'status': newStatus});
    fetchUserRoleAndRequest();
  }

  Future<void> postComment() async {
    final text = commentController.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final name = userDoc['name'];

    await FirebaseFirestore.instance.collection('service_requests')
        .doc(widget.requestId)
        .collection('comments')
        .add({
      'text': text,
      'userId': user.uid,
      'userName': name,
      'timestamp': FieldValue.serverTimestamp(),
    });

    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (requestSnapshot == null || userRole == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back)),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final data = requestSnapshot!;
    final title = data['title'];
    final description = data['description'];
    final status = data['status'];
    final date = (data['date'] as Timestamp).toDate();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back)),
        title: Text("RENT SYNC", style: GoogleFonts.cabin(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Request Details", style: GoogleFonts.cabin(fontSize: 20)),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildDetail("Title:", title),
                  buildDetail("Tenant Name:", tenantName ?? "Unknown"),
                  buildDetail("Description:", description),
                  buildDetail("Urgency:", data['urgency']),
                  buildDetail("Status:", status),
                  buildDetail("Date submitted:", "${date.day} ${_monthName(date.month)} ${date.year}"),
                  SizedBox(height: 25),
                  if (userRole == 'landlord') ...[
                    if (status == 'Pending')
                      buildStatusButton("Mark In Progress", Colors.yellow, () => updateStatus("In Progress")),
                    if (status == 'In Progress')
                      buildStatusButton("Mark Completed", Colors.greenAccent, () => updateStatus("Completed")),
                  ],
                ],
              ),
            ),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text("Comments", style: GoogleFonts.cabin(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 10),
            Container(
              height: 250,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('service_requests')
                    .doc(widget.requestId)
                    .collection('comments')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  final comments = snapshot.data!.docs;

                  if (comments.isEmpty) {
                    return Center(child: Text("No comments yet."));
                  }

                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      final userName = comment['userName'];
                      final text = comment['text'];
                      return ListTile(
                        title: Text(userName, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                        subtitle: Text(text),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(hintText: "Write a comment..."),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: postComment,
                  child: Text("Comment"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          SizedBox(height: 2),
          Text(value, style: GoogleFonts.inter(fontSize: 16)),
        ],
      ),
    );
  }

  Widget buildStatusButton(String text, Color color, VoidCallback onPressed) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 6,
          shadowColor: Colors.black.withOpacity(0.25),
        ),
        onPressed: onPressed,
        child: Text(text, style: GoogleFonts.inter(color: Colors.black)),
      ),
    );
  }

  String _monthName(int month) {
    const months = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month];
  }
}
