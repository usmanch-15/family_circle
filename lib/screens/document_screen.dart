import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../providers/auth_provider.dart';
import '../providers/groups_provider.dart';
import '../services/document_storage_service.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String familyId;
  const DocumentScreen({super.key, required this.familyId});

  @override
  ConsumerState<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  final _service = DocumentStorageService();
  final _titleCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _addDocument() async {
    final title = _titleCtrl.text.trim();
    final url = _urlCtrl.text.trim();
    if (title.isEmpty || url.isEmpty) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _saving = true);
    try {
      await _service.addDocumentByUrl(
        familyId: widget.familyId,
        uploaderUid: user.uid,
        title: title,
        url: url,
      );
      _titleCtrl.clear();
      _urlCtrl.clear();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Document add nahi ho saka: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (ctx, setSheet) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Document Add Karein',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text(
                'Google Drive / Dropbox ka sharable link paste karein',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                    hintText: 'maslan: NIC Copy, Property Papers'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _urlCtrl,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(hintText: 'https://...'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saving
                    ? null
                    : () async {
                  await _addDocument();
                },
                child: _saving
                    ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                    : const Text('Save Karein'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openDocument(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yeh link khul nahi saka')),
      );
    }
  }

  Future<void> _confirmDelete(String docId, String url) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Document Delete Karein?'),
        content: const Text('Yeh document hamesha ke liye delete ho jayega.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed == true) {
      await _service.deleteDocument(docId, url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final familyAsync = ref.watch(singleGroupStreamProvider(widget.familyId));
    final currentUid = ref.watch(currentUserProvider)?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Documents 📄',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _service.documentsStream(widget.familyId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          final docs = snapshot.data!;
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📄', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 14),
                  const Text('Koi document nahi hai',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
                  const SizedBox(height: 4),
                  const Text('Important papers ka link yahan save karein',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              final isAdmin = familyAsync.maybeWhen(
                data: (f) => f?.isAdmin(currentUid) ?? false,
                orElse: () => false,
              );
              final isUploader = doc['uploaderUid'] == currentUid;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  leading: Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.description_outlined,
                        color: AppColors.primary),
                  ),
                  title: Text(doc['title'] ?? 'Untitled',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    Helpers.timeAgo((doc['uploadedAt'] as dynamic).toDate()),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted),
                  ),
                  onTap: () => _openDocument(doc['url'] ?? ''),
                  trailing: (isAdmin || isUploader)
                      ? IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.error, size: 20),
                    onPressed: () =>
                        _confirmDelete(doc['id'], doc['url'] ?? ''),
                  )
                      : const Icon(Icons.open_in_new,
                      size: 16, color: AppColors.textMuted),
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