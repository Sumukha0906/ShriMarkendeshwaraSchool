import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/class_model.dart';
import '../../../core/services/notification_service.dart';

const _kPrimary = Color(0xFF065F46);
const _kDark    = Color(0xFF022C22);
const _kBg      = Color(0xFFF0FDF4);
const _kRed     = Color(0xFFEF4444);
const _kBlue    = Color(0xFF3B82F6);

enum MaterialType {
  NOTES,
  QUESTION_BANK,
  TIMETABLE,
  WORKSHEET,
  ASSIGNMENT,
  OTHER,
}

enum MaterialAudience { CLASS, SUBJECT }

class StudyMaterialsScreen extends ConsumerStatefulWidget {
  final String schoolId;
  final String teacherUid;

  const StudyMaterialsScreen({
    super.key,
    required this.schoolId,
    required this.teacherUid,
  });

  @override
  ConsumerState<StudyMaterialsScreen> createState() =>
      _StudyMaterialsScreenState();
}

class _StudyMaterialsScreenState extends ConsumerState<StudyMaterialsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<ClassModel> _classes = [];
  ClassModel? _selectedClass;
  String _selectedSubject = '';
  MaterialType _type = MaterialType.NOTES;
  MaterialAudience _audience = MaterialAudience.CLASS;
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  List<PlatformFile> _pickedFiles = [];
  bool _uploading = false;
  double _uploadProgress = 0;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadClasses());
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadClasses() async {
    final fs = ref.read(firestoreServiceProvider);
    final classes = await fs
        .streamAllClassesForTeacher(widget.schoolId, widget.teacherUid)
        .first;
    setState(() {
      _classes = classes;
      if (classes.isNotEmpty) {
        _selectedClass = classes.first;
        _updateSubject();
      }
    });
  }

  void _updateSubject() {
    if (_selectedClass == null) return;
    final subs = _selectedClass!.subjectTeachers
        .where((st) => st.teacherUid == widget.teacherUid)
        .map((st) => st.subject)
        .toList();
    _selectedSubject = subs.isNotEmpty ? subs.first : '';
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'ppt', 'pptx', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
    );
    if (result != null) {
      setState(() => _pickedFiles = result.files);
    }
  }

  Future<void> _upload() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }
    if (_pickedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one file')),
      );
      return;
    }

    setState(() {
      _uploading = true;
      _uploadProgress = 0;
    });

    try {
      final storage = FirebaseStorage.instance;
      final fileUrls = <Map<String, String>>[];
      final user = ref.read(currentUserProvider).value;

      for (int i = 0; i < _pickedFiles.length; i++) {
        final f = _pickedFiles[i];
        if (f.path == null) continue;
        final file = File(f.path!);
        final ext  = f.extension ?? 'file';
        final ref  = storage
            .ref('studyMaterials/${widget.schoolId}/${DateTime.now().millisecondsSinceEpoch}_${f.name}');
        await ref.putFile(file);
        final url = await ref.getDownloadURL();
        fileUrls.add({'name': f.name, 'url': url, 'ext': ext});
        setState(() => _uploadProgress = (i + 1) / _pickedFiles.length);
      }

      final fs = ref.read(firestoreServiceProvider);
      await fs.saveStudyMaterial({
        'schoolId':    widget.schoolId,
        'classId':     _selectedClass?.classId ?? '',
        'subject':     _selectedSubject,
        'teacherUid':  widget.teacherUid,
        'teacherName': user?.name ?? '',
        'title':       _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'type':        _type.name,
        'audience':    _audience.name,
        'fileUrls':    fileUrls,
      });
      if (_selectedClass != null) {
        unawaited(_notifyParentsStudyMaterial(
          fs,
          classId: _selectedClass!.classId,
          title: _titleCtrl.text.trim(),
          subject: _selectedSubject,
        ));
      }

      setState(() {
        _uploading    = false;
        _pickedFiles  = [];
        _uploadProgress = 0;
      });
      _titleCtrl.clear();
      _descCtrl.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Materials uploaded successfully!'),
            backgroundColor: _kPrimary,
          ),
        );
        _tabCtrl.animateTo(1);
      }
    } catch (e) {
      setState(() => _uploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: _kRed),
        );
      }
    }
  }

  Future<void> _notifyParentsStudyMaterial(
    dynamic fs, {
    required String classId,
    required String title,
    required String subject,
  }) async {
    try {
      final students = await fs.streamStudentsByClass(classId).first;
      final parentUids = <String>{};
      for (final s in students) {
        if (s.parentUid.isNotEmpty) parentUids.add(s.parentUid as String);
      }
      if (parentUids.isEmpty) return;
      await NotificationService.sendNotification(
        receiverUids: parentUids.toList(),
        title: 'New Study Material — $subject',
        body: title,
        extra: {
          'type':    'STUDY_MATERIAL',
          'classId': classId,
        },
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kDark,
        foregroundColor: Colors.white,
        title: const Text('Study Materials',
            style: TextStyle(fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'Upload'),
            Tab(text: 'My Uploads'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildUploadTab(),
          _buildMyUploadsTab(),
        ],
      ),
    );
  }

  Widget _buildUploadTab() {
    final subjects = _selectedClass?.subjectTeachers
            .where((st) => st.teacherUid == widget.teacherUid)
            .map((st) => st.subject)
            .toList() ??
        [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class
          _label('Class'),
          _dropdown<ClassModel>(
            value: _selectedClass,
            items: _classes,
            display: (c) => c.displayName,
            onChanged: (c) => setState(() {
              _selectedClass = c;
              _updateSubject();
            }),
          ),
          const SizedBox(height: 14),

          // Subject & Audience
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Subject'),
                    if (subjects.isEmpty)
                      Text('All subjects',
                          style: TextStyle(color: Colors.grey[500]))
                    else
                      _dropdown<String>(
                        value: _selectedSubject.isNotEmpty
                            ? _selectedSubject
                            : null,
                        items: subjects,
                        display: (s) => s,
                        onChanged: (s) =>
                            setState(() => _selectedSubject = s ?? ''),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Send To'),
                    _dropdown<MaterialAudience>(
                      value: _audience,
                      items: MaterialAudience.values,
                      display: (a) =>
                          a == MaterialAudience.CLASS ? 'Whole Class' : 'Subject Only',
                      onChanged: (a) =>
                          setState(() => _audience = a ?? MaterialAudience.CLASS),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Material type
          _label('Material Type'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: MaterialType.values.map((t) {
                final selected = _type == t;
                return GestureDetector(
                  onTap: () => setState(() => _type = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected
                          ? _kPrimary
                          : _kPrimary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      t.name,
                      style: TextStyle(
                        color: selected ? Colors.white : _kPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // Title
          _label('Title *'),
          TextField(
            controller: _titleCtrl,
            decoration: _inputDecor('E.g., Chapter 5 Notes'),
          ),
          const SizedBox(height: 14),

          // Description
          _label('Description'),
          TextField(
            controller: _descCtrl,
            maxLines: 3,
            decoration: _inputDecor('Brief description of the material...'),
          ),
          const SizedBox(height: 14),

          // File picker
          _label('Files'),
          GestureDetector(
            onTap: _pickedFiles.isEmpty ? _pickFiles : null,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _kPrimary.withValues(alpha: 0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.upload_file_rounded,
                      color: _kPrimary, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    _pickedFiles.isEmpty
                        ? 'Tap to select files\n(PDF, PPT, DOC, PNG, JPG)'
                        : '${_pickedFiles.length} file(s) selected',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.grey[500], fontSize: 13),
                  ),
                  if (_pickedFiles.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ..._pickedFiles.map((f) => Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Icon(_fileIcon(f.extension ?? ''),
                                  color: _kPrimary, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  f.name,
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() =>
                                    _pickedFiles.remove(f)),
                                child: const Icon(Icons.close,
                                    size: 16, color: _kRed),
                              ),
                            ],
                          ),
                        )),
                    TextButton(
                      onPressed: _pickFiles,
                      child: const Text('Add more files'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Upload progress
          if (_uploading) ...[
            LinearProgressIndicator(
              value: _uploadProgress,
              backgroundColor: _kPrimary.withValues(alpha: 0.2),
              color: _kPrimary,
            ),
            const SizedBox(height: 8),
            Text(
              'Uploading ${(_uploadProgress * 100).toInt()}%',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _uploading ? null : _upload,
              icon: _uploading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload_rounded,
                      color: Colors.white),
              label: Text(
                _uploading ? 'Uploading...' : 'Upload Materials',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const StadiumBorder(),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMyUploadsTab() {
    final fs = ref.watch(firestoreServiceProvider);
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: fs.streamTeacherStudyMaterials(widget.teacherUid),
      builder: (ctx, snap) {
        final items = snap.data ?? [];
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _kPrimary.withValues(alpha: 0.08),
                  ),
                  child: Icon(Icons.folder_open_rounded,
                      size: 38, color: _kPrimary.withValues(alpha: 0.5)),
                ),
                const SizedBox(height: 16),
                Text('No materials uploaded yet',
                    style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (_, i) => _MaterialCard(item: items[i]),
        );
      },
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: Colors.grey[700]),
      ),
    );
  }

  Widget _dropdown<T>({
    required T? value,
    required List<T> items,
    required String Function(T) display,
    required void Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kPrimary.withValues(alpha: 0.25)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(display(item), style: const TextStyle(fontSize: 13)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  InputDecoration _inputDecor(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF0FDF4),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _kPrimary.withValues(alpha: 0.3))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _kPrimary.withValues(alpha: 0.2))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _kPrimary)),
      contentPadding: const EdgeInsets.all(12),
    );
  }

  IconData _fileIcon(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':  return Icons.picture_as_pdf_rounded;
      case 'ppt':
      case 'pptx': return Icons.slideshow_rounded;
      case 'doc':
      case 'docx': return Icons.description_rounded;
      default:     return Icons.image_rounded;
    }
  }
}

class _MaterialCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _MaterialCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final files = (item['fileUrls'] as List?)?.cast<Map>() ?? [];
    // Pattern B — left border accent on material cards
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: const Border(left: BorderSide(color: _kPrimary, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _kPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item['type'] ?? 'NOTES',
                  style: const TextStyle(
                      color: _kPrimary, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              if ((item['subject'] as String?)?.isNotEmpty ?? false)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _kBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item['subject'] ?? '',
                    style: const TextStyle(
                        color: _kBlue, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
              const Spacer(),
              Text(
                _timeAgo(item['createdAt']),
                style: TextStyle(color: Colors.grey[400], fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item['title'] ?? 'Untitled',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          if ((item['description'] as String?)?.isNotEmpty ?? false) ...[
            const SizedBox(height: 4),
            Text(
              item['description'],
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 10),
          Text(
            '${files.length} file${files.length != 1 ? 's' : ''}',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _timeAgo(dynamic ts) {
    if (ts == null) return '';
    try {
      final dt = (ts as dynamic).toDate() as DateTime;
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '';
    }
  }
}
