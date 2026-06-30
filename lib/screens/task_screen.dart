import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/task_model.dart';
import '../models/family_model.dart';
import '../models/user_model.dart';
import '../services/task_service.dart';
import '../widgets/task_tile.dart';
import '../widgets/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskScreen extends StatefulWidget {
  final FamilyModel family;

  const TaskScreen({super.key, required this.family});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final _service = TaskService();
  final _titleCtrl = TextEditingController();
  String? _selectedMemberUid;
  String? _selectedMemberName;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _addTask() async {
    if (_titleCtrl.text.trim().isEmpty || _selectedMemberUid == null) return;

    await _service.addTask(
      familyId: widget.family.id,
      title: _titleCtrl.text.trim(),
      assignedToUid: _selectedMemberUid!,
      assignedToName: _selectedMemberName!,
    );

    _titleCtrl.clear();
    if (mounted) Navigator.pop(context);
  }

  void _showAddSheet(List<UserModel> members) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Naya Task',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              TextField(
                controller: _titleCtrl,
                decoration:
                const InputDecoration(hintText: 'maslan: Bartan dhona'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: members.map((m) {
                  final selected = _selectedMemberUid == m.uid;
                  return ChoiceChip(
                    label: Text(m.name),
                    selected: selected,
                    onSelected: (_) => setSheetState(() {
                      _selectedMemberUid = m.uid;
                      _selectedMemberName = m.name;
                    }),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                        color: selected ? Colors.white : AppColors.textPrimary),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addTask,
                child: const Text('Assign Karein'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Tasks',
            style: TextStyle(color: AppColors.textPrimary)),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('familyIds', arrayContains: widget.family.id)
            .snapshots(),
        builder: (context, memberSnap) {
          if (!memberSnap.hasData) return const LoadingWidget();
          final members = memberSnap.data!.docs
              .map((d) => UserModel.fromMap(d.data() as Map<String, dynamic>))
              .toList();

          return StreamBuilder<List<TaskModel>>(
            stream: _service.tasksStream(widget.family.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LoadingWidget();
              final tasks = snapshot.data!;

              if (tasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Koi task nahi hai',
                          style: TextStyle(color: AppColors.textMuted)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _showAddSheet(members),
                        child: const Text('Task Add Karein'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: tasks.length,
                itemBuilder: (context, i) {
                  final task = tasks[i];
                  return TaskTile(
                    task: task,
                    onToggle: () =>
                        _service.toggleComplete(task.id, task.isCompleted),
                    onDelete: () => _service.deleteTask(task.id),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('familyIds', arrayContains: widget.family.id)
            .snapshots(),
        builder: (context, snap) {
          final members = snap.hasData
              ? snap.data!.docs
              .map((d) =>
              UserModel.fromMap(d.data() as Map<String, dynamic>))
              .toList()
              : <UserModel>[];
          return FloatingActionButton(
            backgroundColor: AppColors.primary,
            onPressed: () => _showAddSheet(members),
            child: const Icon(Icons.add, color: Colors.white),
          );
        },
      ),
    );
  }
}
