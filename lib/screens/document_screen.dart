// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../utils/constants.dart';
// import '../utils/helpers.dart';
// import '../providers/auth_provider.dart';
// import '../services/document_storage_service.dart';
//
// class DocumentScreen extends ConsumerWidget {
//   final String familyId;
//   const DocumentScreen({super.key, required this.familyId});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final service = DocumentStorageService();
//
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         backgroundColor: AppColors.primary,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: const Text('Documents 📄',
//             style: TextStyle(
//                 color: Colors.white, fontWeight: FontWeight.w600)),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add, color: Colors.white),
//             onPressed: () =>
//                 _showAddSheet(context, ref, service),
//           ),
//         ],
//       ),
//       body: StreamBuilder<List<Map<String, dynamic>>>(
//         stream: service.documentsStream(familyId),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           final docs = snapshot.data!;
//
//           if (docs.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: const BoxDecoration(
//                         color: AppColors.cardBg,
//                         shape: BoxShape.circle),
//                     child: const Icon(Icons.folder_outlined,
//                         size: 44, color: AppColors.primary),
//                   ),
//                   const SizedBox(height: 14),
//                   const Text('Koi document nahi hai',
//                       style: TextStyle(
//                           color: AppColors.textMuted, fontSize: 15)),
//                   const SizedBox(height: 8),
//                   const Text(
//                       'Property papers, wills, insurance — safe rakhein',
//                       style: TextStyle(
//                           color: AppColors.textMuted, fontSize: 13),
//                       textAlign: TextAlign.center),
//                   const SizedBox(height: 20),
//                   ElevatedButton.icon(
//                     onPressed: () =>
//                         _showAddSheet(context, ref, service),
//                     icon: const Icon(Icons.add),
//                     label: const Text('Document Add Karein'),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: docs.length,
//             itemBuilder: (context, i) {
//               final doc = docs[i];
//               return Container(
//                 margin: const EdgeInsets.only(bottom: 10),
//                 padding: const EdgeInsets.all(14),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(14),
//                   border: Border.all(color: AppColors.border),
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 46, height: 46,
//                       decoration: BoxDecoration(
//                           color: AppColors.cardBg,
//                           borderRadius:
//                           BorderRadius.circular(12)),
//                       child: const Icon(
//                           Icons.insert_drive_file_rounded,
//                           color: AppColors.primary),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment:
//                         CrossAxisAlignment.start,
//                         children: [
//                           Text(doc['title'] ?? '',
//                               style: const TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600)),
//                           Text(
//                             Helpers.timeAgo(
//                                 (doc['uploadedAt'] as dynamic)
//                                     .toDate()),
//                             style: const TextStyle(
//                                 fontSize: 12,
//                                 color: AppColors.textMuted),
//                           ),
//                         ],
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.open_in_new,
//                           color: AppColors.primary, size: 20),
//                       onPressed: () async {
//                         final url =
//                         Uri.parse(doc['url'] ?? '');
//                         // Open document in browser or PDF viewer
//                         Future<void> _openDocument(String url) async {
//                           final Uri uri = Uri.parse(url);
//                           if (await canLaunchUrl(uri)) {
//                             await launchUrl(uri, mode: LaunchMode.externalApplication);
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(content: Text('Cannot open document')),
//                             );
//                           }
//                         }
//                       },
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.delete_outline,
//                           color: AppColors.error, size: 20),
//                       onPressed: () async {
//                         final confirm = await showDialog<bool>(
//                           context: context,
//                           builder: (ctx) => AlertDialog(
//                             title: const Text('Delete?'),
//                             actions: [
//                               TextButton(
//                                   onPressed: () =>
//                                       Navigator.pop(ctx, false),
//                                   child: const Text('Cancel')),
//                               TextButton(
//                                   onPressed: () =>
//                                       Navigator.pop(ctx, true),
//                                   child: const Text('Delete',
//                                       style: TextStyle(
//                                           color: AppColors.error))),
//                             ],
//                           ),
//                         );
//                         if (confirm == true) {
//                           await service.deleteDocument(
//                               doc['id'], doc['url'] ?? '');
//                         }
//                       },
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   void _showAddSheet(BuildContext context, WidgetRef ref,
//       DocumentStorageService service) {
//     final titleCtrl = TextEditingController();
//     final urlCtrl   = TextEditingController();
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//           borderRadius:
//           BorderRadius.vertical(top: Radius.circular(20))),
//       builder: (context) => Padding(
//         padding: EdgeInsets.only(
//           left: 20, right: 20, top: 20,
//           bottom: MediaQuery.of(context).viewInsets.bottom + 20,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('Document Add Karein',
//                 style: TextStyle(
//                     fontSize: 18, fontWeight: FontWeight.w700)),
//             const SizedBox(height: 16),
//             TextField(
//               controller: titleCtrl,
//               autofocus: true,
//               decoration: const InputDecoration(
//                   hintText: 'maslan: Property Papers, Will'),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: urlCtrl,
//               decoration: const InputDecoration(
//                   hintText:
//                   'Document URL (Google Drive, Dropbox etc.)'),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Tip: Google Drive pe upload karke "Share Link" copy karein aur yahan paste karein',
//               style: TextStyle(
//                   fontSize: 11, color: AppColors.textMuted),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 if (titleCtrl.text.isEmpty ||
//                     urlCtrl.text.isEmpty) return;
//                 final user = ref.read(currentUserProvider);
//                 if (user == null) return;
//
//                 await service.addDocumentByUrl(
//                   familyId:    familyId,
//                   uploaderUid: user.uid,
//                   title:       titleCtrl.text.trim(),
//                   url:         urlCtrl.text.trim(),
//                 );
//                 Navigator.pop(context);
//               },
//               child: const Text('Save Karein'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }