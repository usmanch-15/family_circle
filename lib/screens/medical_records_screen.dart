import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import '../widgets/loading_widget.dart';

class MedicalRecordsScreen extends StatefulWidget {
  final String memberUid;
  final String memberName;

  const MedicalRecordsScreen({
    super.key,
    required this.memberUid,
    required this.memberName,
  });

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _bloodTypeCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _medicinesCtrl = TextEditingController();

  Future<void> _save() async {
    await _firestore
        .collection('medical_records')
        .doc(widget.memberUid)
        .set({
      'memberUid': widget.memberUid,
      'memberName': widget.memberName,
      'bloodType': _bloodTypeCtrl.text.trim(),
      'allergies': _allergiesCtrl.text.trim(),
      'medicines': _medicinesCtrl.text.trim(),
      'updatedAt': Timestamp.now(),
    });
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Save ho gaya')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('${widget.memberName} - Medical',
            style: const TextStyle(color: AppColors.textPrimary)),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore
            .collection('medical_records')
            .doc(widget.memberUid)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LoadingWidget();

          if (snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            _bloodTypeCtrl.text = data['bloodType'] ?? '';
            _allergiesCtrl.text = data['allergies'] ?? '';
            _medicinesCtrl.text = data['medicines'] ?? '';
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Blood Type',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                TextField(
                  controller: _bloodTypeCtrl,
                  decoration: const InputDecoration(hintText: 'maslan: O+'),
                ),
                const SizedBox(height: 16),
                const Text('Allergies',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                TextField(
                  controller: _allergiesCtrl,
                  maxLines: 2,
                  decoration:
                  const InputDecoration(hintText: 'maslan: Peanuts, Dust'),
                ),
                const SizedBox(height: 16),
                const Text('Medicines',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                TextField(
                  controller: _medicinesCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      hintText: 'Roz li jaane wali dawayien'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: _save, child: const Text('Save Karein')),
              ],
            ),
          );
        },
      ),
    );
  }
}