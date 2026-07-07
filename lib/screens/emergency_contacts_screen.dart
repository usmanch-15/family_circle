import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/constants.dart';
import '../widgets/loading_widget.dart';

class EmergencyContactsScreen extends StatefulWidget {
  final String familyId;
  const EmergencyContactsScreen({super.key, required this.familyId});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState
    extends State<EmergencyContactsScreen> {
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _typeCtrl  = TextEditingController();

  final List<Map<String, dynamic>> _types = [
    {'label': 'Doctor',  'icon': Icons.medical_services_outlined, 'color': const Color(0xFF0891B2)},
    {'label': 'Police',  'icon': Icons.local_police_outlined,     'color': const Color(0xFF1D4ED8)},
    {'label': 'Lawyer',  'icon': Icons.gavel_outlined,            'color': const Color(0xFF7C3AED)},
    {'label': 'Hospital','icon': Icons.local_hospital_outlined,   'color': const Color(0xFFEF4444)},
    {'label': 'General', 'icon': Icons.phone_outlined,            'color': AppColors.primary},
  ];

  String _selectedType = 'General';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _typeCtrl.dispose();
    super.dispose();
  }

  Future<void> _addContact() async {
    if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty) return;
    await FirebaseFirestore.instance
        .collection('emergency_contacts')
        .add({
      'familyId':  widget.familyId,
      'name':      _nameCtrl.text.trim(),
      'phone':     _phoneCtrl.text.trim(),
      'type':      _selectedType,
      'createdAt': Timestamp.now(),
    });
    _nameCtrl.clear();
    _phoneCtrl.clear();
    if (mounted) Navigator.pop(context);
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Emergency Contact Add Karein',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                controller: _nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                    hintText: 'maslan: Dr. Ahmed Ali'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    hintText: '0300-1234567'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: _types.map((t) {
                  final sel = _selectedType == t['label'];
                  return ChoiceChip(
                    label: Text(t['label'] as String),
                    selected: sel,
                    onSelected: (_) =>
                        setSheet(() => _selectedType = t['label'] as String),
                    selectedColor: (t['color'] as Color).withOpacity(0.15),
                    labelStyle: TextStyle(
                        color: sel ? t['color'] as Color : AppColors.textPrimary,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.normal),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _addContact, child: const Text('Save Karein')),
            ],
          ),
        ),
      ),
    );
  }

  // Future<void> _call(String phone) async {
  //   final uri = Uri.parse('tel:$phone');
  //   if (await canLaunchUrl(uri)) await launchUrl(uri);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Emergency Contacts 🚨',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('emergency_contacts')
            .where('familyId', isEqualTo: widget.familyId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LoadingWidget();
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                        color: AppColors.cardBg, shape: BoxShape.circle),
                    child: const Icon(Icons.emergency_outlined,
                        size: 44, color: AppColors.error),
                  ),
                  const SizedBox(height: 14),
                  const Text('Koi emergency contact nahi',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showAddSheet,
                    icon: const Icon(Icons.add),
                    label: const Text('Contact Add Karein'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final typeData = _types.firstWhere(
                      (t) => t['label'] == data['type'],
                  orElse: () => _types.last);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                          color: (typeData['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12)),
                      child: Icon(typeData['icon'] as IconData,
                          color: typeData['color'] as Color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['name'] ?? '',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          Text('${data['type']} · ${data['phone']}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          shape: BoxShape.circle),
                      // child: IconButton(
                      //   icon: const Icon(Icons.call_rounded,
                      //       color: AppColors.success, size: 22),
                      //   onPressed: () => _call(data['phone'] ?? ''),
                      // ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _showAddSheet,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}