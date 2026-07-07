import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import '../widgets/loading_widget.dart';

class MedicalRecordsScreen extends StatefulWidget {
  final String memberUid;
  final String memberName;
  const MedicalRecordsScreen(
      {super.key, required this.memberUid, required this.memberName});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  final _bloodTypeCtrl  = TextEditingController();
  final _allergiesCtrl  = TextEditingController();
  final _medicinesCtrl  = TextEditingController();
  final _conditionsCtrl = TextEditingController();
  bool _saving          = false;
  bool _loaded          = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final doc = await FirebaseFirestore.instance
        .collection('medical_records')
        .doc(widget.memberUid)
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      _bloodTypeCtrl.text  = data['bloodType']   ?? '';
      _allergiesCtrl.text  = data['allergies']   ?? '';
      _medicinesCtrl.text  = data['medicines']   ?? '';
      _conditionsCtrl.text = data['conditions']  ?? '';
    }
    setState(() => _loaded = true);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await FirebaseFirestore.instance
        .collection('medical_records')
        .doc(widget.memberUid)
        .set({
      'memberUid':   widget.memberUid,
      'memberName':  widget.memberName,
      'bloodType':   _bloodTypeCtrl.text.trim(),
      'allergies':   _allergiesCtrl.text.trim(),
      'medicines':   _medicinesCtrl.text.trim(),
      'conditions':  _conditionsCtrl.text.trim(),
      'updatedAt':   Timestamp.now(),
    });
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('✅ Medical records save ho gaye!'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  void dispose() {
    _bloodTypeCtrl.dispose();
    _allergiesCtrl.dispose();
    _medicinesCtrl.dispose();
    _conditionsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('${widget.memberName} — Medical',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 18, height: 18,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: !_loaded
          ? const LoadingWidget()
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF1D4ED8), size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Yeh data sirf family members dekh sakte hain. Sensitive info safely store hoti hai.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF1D4ED8), height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _Field(
            icon: Icons.water_drop_outlined,
            iconColor: const Color(0xFFEF4444),
            label: 'Blood Type',
            hint: 'maslan: O+, A-, B+',
            controller: _bloodTypeCtrl,
          ),
          _Field(
            icon: Icons.warning_amber_outlined,
            iconColor: const Color(0xFFD97706),
            label: 'Allergies',
            hint: 'maslan: Peanuts, Penicillin, Dust',
            controller: _allergiesCtrl,
            maxLines: 2,
          ),
          _Field(
            icon: Icons.medication_outlined,
            iconColor: const Color(0xFF059669),
            label: 'Daily Medicines',
            hint: 'Roz li jaane wali dawayein',
            controller: _medicinesCtrl,
            maxLines: 3,
          ),
          _Field(
            icon: Icons.medical_information_outlined,
            iconColor: const Color(0xFF7C3AED),
            label: 'Medical Conditions',
            hint: 'maslan: Diabetes, Blood Pressure, Asthma',
            controller: _conditionsCtrl,
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save Karein',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label, hint;
  final TextEditingController controller;
  final int maxLines;

  const _Field({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ),
    );
  }
}