import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/class_model.dart';
import '../../../core/models/announcement.dart';

const _kPrimary = Color(0xFF065F46);
const _kDark    = Color(0xFF022C22);
const _kBg      = Color(0xFFF0FDF4);
const _kOrange  = Color(0xFFD97706);
const _kRed     = Color(0xFFEF4444);

class ClassAnnouncementScreen extends ConsumerStatefulWidget {
  final String schoolId;
  final String teacherUid;
  /// When true, only TEACHERS audience is available (for admin/staff use)
  final bool teacherOnly;
  /// When true, shows school-wide audience options: Teachers, Parents, Staff, All
  /// (no Class option). Used by Admin / Principal / Management.
  final bool schoolWideOnly;
  /// When true, shows the "All Announcements" tab (Principal/Admin/Management).
  final bool showAllAnnouncements;

  const ClassAnnouncementScreen({
    super.key,
    required this.schoolId,
    required this.teacherUid,
    this.teacherOnly = false,
    this.schoolWideOnly = false,
    this.showAllAnnouncements = false,
  });

  @override
  ConsumerState<ClassAnnouncementScreen> createState() =>
      _ClassAnnouncementScreenState();
}

class _ClassAnnouncementScreenState
    extends ConsumerState<ClassAnnouncementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<ClassModel> _classes = [];
  ClassModel? _selectedClass;
  late AnnouncementAudience _audience;
  bool _requiresAck = false;
  bool _saving = false;

  final _titleCtrl = TextEditingController();
  final _bodyCtrl  = TextEditingController();

  @override
  void initState() {
    super.initState();
    _audience = widget.teacherOnly
        ? AnnouncementAudience.TEACHERS
        : widget.schoolWideOnly
            ? AnnouncementAudience.STAFF
            : AnnouncementAudience.CLASS;
    // Tabs: New | My Announcements | Announcements (for me) | All (if privileged)
    final tabCount = widget.showAllAnnouncements ? 4 : 3;
    _tabCtrl = TabController(length: tabCount, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadClasses());
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadClasses() async {
    if (widget.teacherOnly || widget.schoolWideOnly) return;
    final fs = ref.read(firestoreServiceProvider);
    final classes = await fs
        .streamAllClassesForTeacher(widget.schoolId, widget.teacherUid)
        .first;
    setState(() {
      _classes = classes;
      if (classes.isNotEmpty) _selectedClass = classes.first;
    });
  }

  Future<void> _post() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }
    if (_bodyCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the announcement body')),
      );
      return;
    }
    if (_audience == AnnouncementAudience.CLASS && _selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a class')),
      );
      return;
    }

    setState(() => _saving = true);
    final fs   = ref.read(firestoreServiceProvider);
    final user = ref.read(currentUserProvider).value;

    try {
      final announcement = Announcement(
        announcementId:  '',
        schoolId:        widget.schoolId,
        title:           _titleCtrl.text.trim(),
        body:            _bodyCtrl.text.trim(),
        createdBy:       widget.teacherUid,
        createdByName:   user?.name ?? 'Teacher',
        audience:        _audience,
        targetClassId:   _selectedClass?.classId ?? '',
        targetClassName: _selectedClass?.displayName ?? '',
        requiresAck:     _requiresAck,
        ackedBy:         const [],
      );
      await fs.createAnnouncement(announcement);
      setState(() => _saving = false);
      _titleCtrl.clear();
      _bodyCtrl.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Announcement posted!'),
            backgroundColor: _kPrimary,
          ),
        );
        _tabCtrl.animateTo(1);
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: _kRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kDark,
        foregroundColor: Colors.white,
        title: const Text('Announcements',
            style: TextStyle(fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            const Tab(text: 'New'),
            const Tab(text: 'My Announcements'),
            const Tab(text: 'For Me'),
            if (widget.showAllAnnouncements) const Tab(text: 'All'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildCreateTab(),
          _buildMyAnnouncementsTab(),
          _buildForMeTab(),
          if (widget.showAllAnnouncements) _buildAllAnnouncementsTab(),
        ],
      ),
    );
  }

  Widget _buildCreateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Audience
          _sectionLabel('Post To'),
          const SizedBox(height: 8),
          if (widget.teacherOnly)
            _audienceChip('Teachers', AnnouncementAudience.TEACHERS)
          else if (widget.schoolWideOnly)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _audienceChip('Staff', AnnouncementAudience.STAFF),
                _audienceChip('Teachers Only', AnnouncementAudience.TEACHERS),
                _audienceChip('Parents', AnnouncementAudience.PARENTS),
                _audienceChip('All', AnnouncementAudience.ALL),
              ],
            )
          else
            Row(
              children: [
                _audienceChip('Class', AnnouncementAudience.CLASS),
                const SizedBox(width: 8),
                _audienceChip('All', AnnouncementAudience.ALL),
              ],
            ),
          const SizedBox(height: 14),

          // Class selector (only if CLASS audience)
          if (_audience == AnnouncementAudience.CLASS) ...[
            _sectionLabel('Class'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ClassModel>(
                  value: _selectedClass,
                  isExpanded: true,
                  items: _classes
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.displayName),
                          ))
                      .toList(),
                  onChanged: (c) => setState(() => _selectedClass = c),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Title
          _sectionLabel('Title *'),
          const SizedBox(height: 8),
          _textField(_titleCtrl, 'Announcement title...'),
          const SizedBox(height: 14),

          // Body
          _sectionLabel('Message *'),
          const SizedBox(height: 8),
          _textField(_bodyCtrl, 'Type the full announcement...', lines: 5),
          const SizedBox(height: 14),

          // Requires acknowledgement
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline,
                    color: _kOrange, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Requires Acknowledgment',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      Text(
                        'Parents/teachers must confirm they saw this',
                        style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _requiresAck,
                  onChanged: (v) => setState(() => _requiresAck = v),
                  activeColor: _kOrange,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _post,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.campaign_rounded,
                      color: Colors.white),
              label: Text(
                _saving ? 'Posting...' : 'Post Announcement',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kOrange,
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

  Widget _buildMyAnnouncementsTab() {
    final fs = ref.watch(firestoreServiceProvider);
    return StreamBuilder<List<Announcement>>(
      stream: fs.streamSchoolAllAnnouncements(widget.schoolId),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const Center(child: CircularProgressIndicator(color: _kOrange));
        }
        if (snap.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: _kRed.withValues(alpha: 0.5)),
                const SizedBox(height: 12),
                Text('Could not load announcements',
                    style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text('${snap.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[400], fontSize: 11)),
              ],
            ),
          );
        }
        final all = snap.data ?? [];
        final mine = all
            .where((a) => a.createdBy == widget.teacherUid)
            .toList();

        if (mine.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.campaign_outlined,
                    size: 60, color: _kOrange.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text('No announcements posted yet',
                    style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          );
        }
        return _announcementList(mine, _kOrange);
      },
    );
  }

  /// Announcements sent TO the current user (audience matches their role).
  Widget _buildForMeTab() {
    final fs = ref.watch(firestoreServiceProvider);
    return StreamBuilder<List<Announcement>>(
      stream: fs.streamSchoolAllAnnouncements(widget.schoolId),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const Center(child: CircularProgressIndicator(color: _kPrimary));
        }
        if (snap.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: _kRed.withValues(alpha: 0.5)),
                const SizedBox(height: 12),
                Text('Could not load announcements',
                    style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text('${snap.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[400], fontSize: 11)),
              ],
            ),
          );
        }
        final all = snap.data ?? [];
        // Include ALL and STAFF (covers admin/principal/management/teacher),
        // TEACHERS if teacher, PARENTS if parent — but on this screen the
        // user is staff so exclude CLASS-only ones unless they're the creator.
        final forMe = all.where((a) {
          if (a.createdBy == widget.teacherUid) return false; // shown in My tab
          return a.audience == AnnouncementAudience.ALL ||
              a.audience == AnnouncementAudience.STAFF ||
              a.audience == AnnouncementAudience.TEACHERS;
        }).toList();

        if (forMe.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none_rounded,
                    size: 60, color: _kPrimary.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text('No announcements for you yet',
                    style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          );
        }
        return _announcementList(forMe, _kPrimary,
            isRecipientView: true, viewerUid: widget.teacherUid);
      },
    );
  }

  /// All announcements in the school (Principal / Admin / Management only).
  Widget _buildAllAnnouncementsTab() {
    final fs = ref.watch(firestoreServiceProvider);
    return StreamBuilder<List<Announcement>>(
      stream: fs.streamSchoolAllAnnouncements(widget.schoolId),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const Center(child: CircularProgressIndicator(color: _kOrange));
        }
        if (snap.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: _kRed.withValues(alpha: 0.5)),
                const SizedBox(height: 12),
                Text('Could not load announcements',
                    style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text('${snap.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[400], fontSize: 11)),
              ],
            ),
          );
        }
        final all = snap.data ?? [];
        if (all.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.campaign_outlined,
                    size: 60, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('No announcements yet',
                    style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          );
        }
        return _announcementList(all, _kOrange);
      },
    );
  }

  Widget _announcementList(
    List<Announcement> items,
    Color accent, {
    bool isRecipientView = false,
    String viewerUid = '',
  }) {
    return ListView.builder(
      primary: false,
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        final a = items[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 4, color: accent),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(a.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: Color(0xFF0A0F1E))),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: accent.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  a.audience == AnnouncementAudience.CLASS &&
                                          a.targetClassName.isNotEmpty
                                      ? 'Class: ${a.targetClassName}'
                                      : a.audience.name,
                                  style: TextStyle(
                                      color: accent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (a.createdByName.isNotEmpty)
                                Text('From: ${a.createdByName}',
                                    style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                              const Spacer(),
                              Text(
                                'To: ${a.audience == AnnouncementAudience.CLASS && a.targetClassName.isNotEmpty ? a.targetClassName : a.audience.name}',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: accent.withValues(alpha: 0.8)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            a.body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                          if (a.publishedAt != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMM d, yyyy · h:mm a').format(a.publishedAt!),
                              style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                            ),
                          ],
                          if (a.requiresAck) ...[
                            const SizedBox(height: 6),
                            if (isRecipientView)
                              _buildRecipientAckWidget(a, viewerUid)
                            else
                              GestureDetector(
                                onTap: () => _showAckDetail(ctx, a),
                                child: Row(
                                  children: [
                                    Icon(Icons.people_outline, size: 12, color: accent),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${a.ackedBy.length} acknowledged — tap to view',
                                      style: TextStyle(
                                        color: accent,
                                        fontSize: 11,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecipientAckWidget(Announcement a, String viewerUid) {
    final hasAcked = a.hasUserAcked(viewerUid);
    if (hasAcked) {
      return const Row(
        children: [
          Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 14),
          SizedBox(width: 4),
          Text(
            'Acknowledged',
            style: TextStyle(
              color: Color(0xFF059669),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }
    return GestureDetector(
      onTap: () => ref
          .read(firestoreServiceProvider)
          .acknowledgeAnnouncement(a.announcementId, viewerUid),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _kOrange,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'Acknowledge',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showAckDetail(BuildContext context, Announcement a) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AckDetailSheet(
        announcement: a,
        schoolId: widget.schoolId,
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: _kPrimary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _audienceChip(String label, AnnouncementAudience value) {
    final selected = _audience == value;
    return GestureDetector(
      onTap: () => setState(() => _audience = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _kOrange : _kOrange.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : _kOrange,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _textField(TextEditingController ctrl, String hint, {int lines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: lines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF0FDF4),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _kPrimary.withValues(alpha: 0.3))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _kPrimary.withValues(alpha: 0.3))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }
}

// ─── Acknowledgement detail bottom sheet ─────────────────────────────────────

class _AckDetailSheet extends ConsumerStatefulWidget {
  final Announcement announcement;
  final String schoolId;

  const _AckDetailSheet({
    required this.announcement,
    required this.schoolId,
  });

  @override
  ConsumerState<_AckDetailSheet> createState() => _AckDetailSheetState();
}

class _AckDetailSheetState extends ConsumerState<_AckDetailSheet> {
  List<Map<String, dynamic>>? _detail;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final detail = await ref.read(firestoreServiceProvider).getAnnouncementAckDetail(
      announcementId: widget.announcement.announcementId,
      schoolId: widget.schoolId,
      audience: widget.announcement.audience.name,
      classId: widget.announcement.targetClassId.isNotEmpty
          ? widget.announcement.targetClassId
          : null,
    );
    if (mounted) setState(() { _detail = detail; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.announcement;
    final ackedCount = _detail?.where((e) => e['isAcked'] as bool).length
        ?? a.ackedBy.length;
    final total = _detail?.length ?? 0;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      color: _kOrange, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Acknowledgements',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _kOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      total > 0 ? '$ackedCount / $total' : '$ackedCount acked',
                      style: const TextStyle(
                        color: _kOrange,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: _kOrange))
                  : (_detail == null || _detail!.isEmpty)
                      ? Center(
                          child: Text('No recipients found',
                              style: TextStyle(color: Colors.grey[500])))
                      : ListView.builder(
                          controller: ctrl,
                          itemCount: _detail!.length,
                          itemBuilder: (_, i) {
                            final e = _detail![i];
                            final isAcked = e['isAcked'] as bool;
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 18,
                                backgroundColor: isAcked
                                    ? const Color(0xFF059669)
                                        .withValues(alpha: 0.12)
                                    : Colors.grey[100],
                                child: Icon(
                                  isAcked
                                      ? Icons.check_rounded
                                      : Icons.hourglass_empty_rounded,
                                  color: isAcked
                                      ? const Color(0xFF059669)
                                      : Colors.grey[400],
                                  size: 16,
                                ),
                              ),
                              title: Text(e['name'] as String,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                              subtitle: Text(e['subLabel'] as String,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[500])),
                              trailing: isAcked
                                  ? const Text('Acknowledged',
                                      style: TextStyle(
                                          color: Color(0xFF059669),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600))
                                  : Text('Pending',
                                      style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 11)),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
