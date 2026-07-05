import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../providers/auth_provider.dart';
import '../models/task_model.dart';
import '../models/family_model.dart';
import '../models/user_model.dart';
import '../services/task_service.dart';
import '../widgets/loading_widget.dart';

class TaskScreen extends ConsumerStatefulWidget {
  final FamilyModel family;
  const TaskScreen({super.key, required this.family});

  @override
  ConsumerState<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends ConsumerState<TaskScreen> with SingleTickerProviderStateMixin {
  final _service    = TaskService();
  final _titleCtrl  = TextEditingController();
  late TabController _tabCtrl;
  String? _selectedMemberUid;
  String? _selectedMemberName;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _addTask() async {
    if (_titleCtrl.text.trim().isEmpty || _selectedMemberUid == null) return;
    await _service.addTask(
      familyId:       widget.family.id,
      title:          _titleCtrl.text.trim(),
      assignedToUid:  _selectedMemberUid!,
      assignedToName: _selectedMemberName!,
    );
    _titleCtrl.clear();
    _selectedMemberUid  = null;
    _selectedMemberName = null;
    if (mounted) Navigator.pop(context);
  }

  void _showAddSheet(List<UserModel> members) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                controller: _titleCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'maslan: Bartan dhona, Bill pay karna',
                  prefixIcon: Icon(Icons.task_outlined, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Kise assign karein?',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: members.map((m) {
                  final sel = _selectedMemberUid == m.uid;
                  return ChoiceChip(
                    label: Text(m.name),
                    selected: sel,
                    onSelected: (_) => setSheetState(() {
                      _selectedMemberUid  = m.uid;
                      _selectedMemberName = m.name;
                    }),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                        color: sel ? Colors.white : AppColors.textPrimary,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.normal),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _selectedMemberUid != null ? _addTask : null,
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
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Tasks',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Baaki'),
            Tab(text: 'Complete'),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('familyIds', arrayContains: widget.family.id)
            .snapshots(),
        builder: (context, memberSnap) {
          final members = memberSnap.hasData
              ? memberSnap.data!.docs
              .map((d) => UserModel.fromMap(d.data() as Map<String, dynamic>))
              .toList()
              : <UserModel>[];

          return StreamBuilder<List<TaskModel>>(
            stream: _service.tasksStream(widget.family.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LoadingWidget();
              final all      = snapshot.data!;
              final pending  = all.where((t) => !t.isCompleted).toList();
              final completed = all.where((t) => t.isCompleted).toList();

              return TabBarView(
                controller: _tabCtrl,
                children: [
                  _TaskList(
                    tasks: pending,
                    service: _service,
                    emptyMsg: 'Koi task baaki nahi!',
                    emptyIcon: Icons.check_circle_outline,
                  ),
                  _TaskList(
                    tasks: completed,
                    service: _service,
                    emptyMsg: 'Abhi koi task complete nahi hua',
                    emptyIcon: Icons.pending_outlined,
                  ),
                ],
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
              .map((d) => UserModel.fromMap(d.data() as Map<String, dynamic>))
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
}class _TaskList extends StatelessWidget {
  final List<TaskModel> tasks;
  final TaskService service;
  final String emptyMsg;
  final IconData emptyIcon;

  const _TaskList({
    required this.tasks,
    required this.service,
    required this.emptyMsg,
    required this.emptyIcon,
  });  // ← YAHAN PAR BRACKET BAND KRO, KUCH AURA MA NAHI

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.cardBg, shape: BoxShape.circle),
              child: Icon(emptyIcon, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 14),
            Text(emptyMsg, style: const TextStyle(color: AppColors.textMuted, fontSize: 15)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, i) {
        final task = tasks[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: task.isCompleted ? AppColors.success.withOpacity(0.3) : AppColors.border),
          ),
          child: ListTile(
            leading: GestureDetector(
              onTap: () => service.toggleComplete(task.id, task.isCompleted),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 26, height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isCompleted ? AppColors.success : Colors.transparent,
                  border: Border.all(
                      color: task.isCompleted ? AppColors.success : AppColors.border, width: 2),
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600,
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                color: task.isCompleted ? AppColors.textMuted : AppColors.textPrimary,
              ),
            ),
            subtitle: Row(
              children: [
                const Icon(Icons.person_outline, size: 12, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(task.assignedToName,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 18, color: AppColors.error),
              onPressed: () => service.deleteTask(task.id),
            ),
          ),
        );
      },
    );
  }
}