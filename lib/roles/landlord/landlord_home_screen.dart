import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_sync/roles/landlord/request_details.dart';
import 'package:rent_sync/widgets/side_menu.dart';

class LandlordHomePage extends StatefulWidget {
  
 LandlordHomePage({super.key}) {print("📦 LandlordHomePage constructor called");}
  

  @override
  State<LandlordHomePage> createState() => _LandlordHomePageState();
}

class _LandlordHomePageState extends State<LandlordHomePage> {
  
  
  String? landlordId;

  @override
  void initState() {
  super.initState();
  landlordId = FirebaseAuth.instance.currentUser?.uid;
  print("🔥 initState() called");
  print("🔥 Logged-in landlord UID: $landlordId");
}
  

  @override
  Widget build(BuildContext context) {
    if (landlordId == null) {
      // Show loading while landlordId is null (should be rare)
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      drawer: SideMenu(role: "landlord",userId: landlordId!,),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu_outlined, size: 30),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          "RENT SYNC",
          style: GoogleFonts.cabin(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Service Requests",
                style: GoogleFonts.cabin(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('service_requests')
                    .where('landlordId', isEqualTo: landlordId)
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No service requests found."));
                  }

                  final requests = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final data = requests[index];
                      final title = data['title'];
                      final urgency = data['urgency'];
                      final status = data['status'];
                      final location = data['location'];
                      final room = data['roomNumber'];
                      final userId = data['userId'];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RequestDetailsPage(requestId: data.id),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.white,
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(title,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text(urgency,
                                        style: TextStyle(
                                            color: _urgencyColor(urgency),
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text("$location - $room"),
                                Text("Tenant ID: $userId"),
                                const SizedBox(height: 6),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _statusColor(status),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(status, style: TextStyle(color: Colors.black)),
                                ),
                              ],
                            ),
                          ),
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

  Color _urgencyColor(String urgency) {
    switch (urgency) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.greenAccent;
      case 'In Progress':
        return Colors.yellow;
      case 'Completed':
        return Colors.grey;
      default:
        return Colors.white;
    }
  }
}
