import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rent_sync/widgets/custom_appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rent_sync/services/firestore_service.dart';

class NewServiceRequestPage extends StatefulWidget {
  const NewServiceRequestPage({super.key});

  @override
  State<NewServiceRequestPage> createState() => _NewServiceRequestPageState();
}

class _NewServiceRequestPageState extends State<NewServiceRequestPage> {

  final user = FirebaseAuth.instance.currentUser;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _roomController = TextEditingController();

  String _selectedCategory = 'Plumbing';
  String _selectedUrgency = 'Low';

  String? landlordId;

@override
void initState() {
  super.initState();
  _fetchLandlordId();
}

Future<void> _fetchLandlordId() async {
  if (user == null) return;

  final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
  if (doc.exists) {
    setState(() {
      landlordId = doc.data()?['landlordId'];
    });
  }
}


  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }
Future<void> _submitRequest() async {
  if (_titleController.text.trim().isEmpty || _roomController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Title and Room number are required")));
    return;
  }

  try {
    await FirestoreService().addServiceRequest(
      userId: user!.uid,
      landlordId: landlordId,  // pass landlordId here

      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      location: _locationController.text.trim(),
      category: _selectedCategory,
      urgency: _selectedUrgency,
      status: "Pending",
      date: DateTime.now(),
      roomNumber: _roomController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Request submitted")));
    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(onMenuPressed: () {
        Navigator.pop(context);
      }),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New service request', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 24),
              _buildLabel('Title'),
              _buildTextField(_titleController),

              _buildLabel('Description'),
              _buildTextField(_descriptionController, maxLines: 3),

              _buildLabel('Location within property'),
              _buildTextField(_locationController),

              _buildLabel('Room Number'),
              _buildTextField(_roomController),

              _buildLabel('Category'),
              _buildDropdown(
                value: _selectedCategory,
                items: ['Plumbing', 'Electrical', 'Cleaning', 'Other'],
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),

              _buildLabel('Urgency'),
              _buildDropdown(
                value: _selectedUrgency,
                items: ['Low', 'Medium', 'High'],
                onChanged: (val) => setState(() => _selectedUrgency = val!),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xffD18787),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.upload, size: 16),
                            SizedBox(width: 6),
                            Text('Upload Photo'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildButton(
                    icon: Icons.calendar_today,
                    label: 'Preferred Date',
                    color: Color(0xff87AED1),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_pickedImage != null)
                Center(
                  child: Image.file(
                    _pickedImage!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: _submitRequest,
                  child: _buildSubmitButton(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 4),
        child: Text(text, style: TextStyle(fontSize: 16)),
      );

  Widget _buildTextField(TextEditingController controller, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: Offset(0, 3),
              blurRadius: 6)
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: Offset(0, 3),
              blurRadius: 6)
        ],
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: SizedBox(),
        onChanged: onChanged,
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
      ),
    );
  }

  Widget _buildButton(
      {required IconData icon, required String label, required Color color}) {
    return Expanded(
      child: Container(
        height: 50,
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(label)
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: 160,
      height: 50,
      decoration: BoxDecoration(
          color: Colors.grey.shade600, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.send, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text('Submit Request', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
