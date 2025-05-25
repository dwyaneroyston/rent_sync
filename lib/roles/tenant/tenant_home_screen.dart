import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_sync/roles/landlord/request_details.dart';
import 'package:rent_sync/roles/tenant/service_request.dart';
import 'package:rent_sync/widgets/add_button.dart';
import 'package:rent_sync/widgets/request_card.dart';
import 'package:rent_sync/widgets/side_menu.dart';
class TenantHomeScreen extends StatefulWidget {
  const TenantHomeScreen({super.key});

  @override
  State<TenantHomeScreen> createState() => _TenantHomeScreenState();
}


class _TenantHomeScreenState extends State<TenantHomeScreen> {
    final userId = FirebaseAuth.instance.currentUser?.uid;

  final user = FirebaseAuth.instance.currentUser;
  String? tenantName;

  @override
  void initState() {
    super.initState();
    fetchTenantName();
  }

  Future<void> fetchTenantName() async {
    if (user == null) return;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    if (userDoc.exists && userDoc.data()!.containsKey('name')) {
      setState(() {
        tenantName = userDoc['name'];
      });
    } else {
      setState(() {
        tenantName = "Unknown";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (tenantName == null) {
      return Scaffold(
        appBar: AppBar(title: Text("RENTSYNC")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      drawer: SideMenu(role: "tenant",userId: userId!,),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu_outlined, size: 30),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Text(
          "RENTSYNC",
          style: GoogleFonts.cabin(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          SizedBox(width: 50),
          AddButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewServiceRequestPage()),
              );
            },
          ),
          SizedBox(width: 14),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(left: 18, bottom: 18),
              child: Text(
                "My requests",
                style: GoogleFonts.cabin(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('service_requests')
                    .where('userId', isEqualTo: user!.uid)
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error loading requests."));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No service requests found."));
                  }

                  final requests = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      final title = request['title'];
                      final status = request['status'];
                      final date = (request['date'] as Timestamp).toDate();
                      final formattedDate = "${date.day}/${date.month}/${date.year}";

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RequestDetailsPage(
                                requestId: request.id,
                              ),
                            ),
                          );
                        },
                        child: RequestCard(
                          title: title,
                          date: formattedDate,
                          status: status,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
