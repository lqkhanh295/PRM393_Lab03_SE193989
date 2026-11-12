import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/ticket_model.dart';
import '../../models/event_model.dart';
import '../../models/screen_state.dart';
import '../../services/firestore_service.dart';
import '../../services/remote_config_service.dart';
import '../../viewmodels/live_event_vm.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/question_card.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/app_button.dart';

/// S21 & S22: Live Event Companion & Speaker Q&A Screen
/// Anti-slop Live Conference Companion: flat hairline cards, crisp live badge, tactile Q&A input.
class LiveCompanionScreen extends StatefulWidget {
  final TicketModel ticket;

  const LiveCompanionScreen({super.key, required this.ticket});

  @override
  State<LiveCompanionScreen> createState() => _LiveCompanionScreenState();
}

class _LiveCompanionScreenState extends State<LiveCompanionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _questionController = TextEditingController();
  EventModel? _event;
  bool _isLoadingEvent = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<LiveEventViewModel>().loadLiveQuestions(widget.ticket.eventId);
      final evt = await context.read<FirestoreService>().getEventById(widget.ticket.eventId);
      if (mounted) {
        setState(() {
          _event = evt;
          _isLoadingEvent = false;
        });
        if (evt != null) {
          context.read<LiveEventViewModel>().updateCurrentSessionIndex(evt.sessions);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final liveVM = context.watch<LiveEventViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'Live Companion',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'TRỰC TIẾP HỘI TRƯỜNG',
                  style: TextStyle(
                    fontSize: 9,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppTheme.hairline, width: 1),
                bottom: BorderSide(color: AppTheme.hairline, width: 1),
              ),
              color: AppTheme.surface,
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.obsidian,
              unselectedLabelColor: AppTheme.textMuted,
              indicatorColor: AppTheme.primary,
              indicatorWeight: 2,
              tabs: const [
                Tab(
                  icon: Icon(Icons.timeline_rounded, size: 18),
                  text: 'Lịch trình trực tiếp',
                ),
                Tab(
                  icon: Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  text: 'Hỏi đáp diễn giả',
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Live Timeline View
          _buildLiveTimelineTab(context),

          // Tab 2: Live Q&A Stream
          _buildSpeakerQATab(context, liveVM, user),
        ],
      ),
    );
  }

  Widget _buildLiveTimelineTab(BuildContext context) {
    if (_isLoadingEvent) {
      return const LoadingView(message: 'Đang tải lịch trình trực tiếp...');
    }

    final sessions = _event?.sessions ?? [];
    if (sessions.isEmpty) {
      return const EmptyView(
        title: 'Chưa có lịch trình phiên',
        message: 'Ban tổ chức sự kiện chưa cập nhật lịch trình các phiên chi tiết.',
      );
    }

    int activeIdx = 0;
    final now = DateTime.now();
    for (int i = 0; i < sessions.length; i++) {
      final s = sessions[i];
      final parts = s.time.split('-');
      if (parts.isNotEmpty) {
        final startParts = parts[0].trim().split(':');
        if (startParts.length == 2) {
          final h = int.tryParse(startParts[0]);
          final m = int.tryParse(startParts[1]);
          if (h != null && m != null) {
            final sessionTime = DateTime(now.year, now.month, now.day, h, m);
            if (now.isAfter(sessionTime)) {
              activeIdx = i;
            }
          }
        }
      }
    }
    if (activeIdx >= sessions.length) activeIdx = sessions.length - 1;
    final currentSession = sessions[activeIdx];
    final nextSessions = sessions.asMap().entries.where((e) => e.key != activeIdx).map((e) => e.value).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingScreenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Ongoing Session Highlight
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              border: Border.all(color: AppTheme.primary, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'PHIÊN HIỆN TẠI · ${currentSession.time}',
                        style: const TextStyle(
                          color: AppTheme.onPrimaryContainer,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Icon(Icons.sensors, color: AppTheme.primary, size: 18),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  currentSession.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurface,
                    height: 1.3,
                  ),
                ),
                if (currentSession.speakerName.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Diễn giả: ${currentSession.speakerName}',
                    style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  ),
                ],
                const SizedBox(height: 16),
                AppOutlinedButton(
                  label: 'Tải Slide Báo Cáo Của Diễn Giả (PDF)',
                  icon: Icons.download_rounded,
                  onPressed: () async {
                    try {
                      final doc = pw.Document();
                      doc.addPage(
                        pw.Page(
                          pageFormat: PdfPageFormat.a4,
                          build: (pw.Context ctx) {
                            return pw.Container(
                              padding: const pw.EdgeInsets.all(32),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    'TRUONG DAI HOC FPT TP. HO CHI MINH',
                                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                                  ),
                                  pw.SizedBox(height: 6),
                                  pw.Text(
                                    'TAI LIEU DIEN GIA & SLIDE PHIEN THUYET TRINH',
                                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                                  ),
                                  pw.Divider(thickness: 1.5, color: PdfColors.grey400),
                                  pw.SizedBox(height: 14),
                                  pw.Text('Chu de: ${currentSession.title.isNotEmpty ? currentSession.title : "Chuyen de FPTU"}', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                                  pw.SizedBox(height: 8),
                                  pw.Text('Dien gia: ${currentSession.speakerName.isNotEmpty ? currentSession.speakerName : "Chuyen gia khach moi"}', style: const pw.TextStyle(fontSize: 12)),
                                  pw.SizedBox(height: 6),
                                  pw.Text('Khung gio: ${currentSession.time.isNotEmpty ? currentSession.time : "13:30 - 17:30"}', style: const pw.TextStyle(fontSize: 12)),
                                  pw.SizedBox(height: 18),
                                  pw.Container(
                                    padding: const pw.EdgeInsets.all(16),
                                    decoration: pw.BoxDecoration(
                                      color: PdfColors.grey100,
                                      borderRadius: pw.BorderRadius.circular(8),
                                    ),
                                    child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text('TOM TAT NOI DUNG & TAI LIEU CHUYEN MON:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                                        pw.SizedBox(height: 8),
                                        pw.Text('1. Tong quan cac xu huong cong nghe va ky thuat phan mem moi nhat.', style: const pw.TextStyle(fontSize: 10)),
                                        pw.Text('2. So do kien truc thuc te va huong dan lap trinh ung dung.', style: const pw.TextStyle(fontSize: 10)),
                                        pw.Text('3. Bo tai lieu Slide va ma nguon tham khao doc quyen cho sinh vien tham du.', style: const pw.TextStyle(fontSize: 10)),
                                      ],
                                    ),
                                  ),
                                  pw.Spacer(),
                                  pw.Text('FPTU Campus Event - He Thong Quan Ly Su Kien Sinh Vien FPT', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                      final bytes = await doc.save();
                      try {
                        await Printing.sharePdf(
                          bytes: bytes,
                          filename: 'Slide_Dien_Gia_${currentSession.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.pdf',
                        );
                      } catch (_) {
                        await Printing.layoutPdf(
                          name: 'Slide_Dien_Gia',
                          onLayout: (PdfPageFormat format) async => bytes,
                        );
                      }
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi xuất tài liệu: $e')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          if (nextSessions.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'CÁC PHIÊN TIẾP THEO',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMuted,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            for (final session in nextSessions)
              _buildNextSessionTile(
                session.time,
                session.title,
                session.speakerName,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildNextSessionTile(String time, String title, String speaker) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.hairline, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceSubtle,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppTheme.hairline, width: 1),
            ),
            child: Text(
              time,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.obsidian,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  speaker,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakerQATab(BuildContext context, LiveEventViewModel liveVM, dynamic user) {
    final isQAEnabled = context.watch<RemoteConfigService>().enableLiveQA;
    return Column(
      children: [
        // Question list
        Expanded(
          child: switch (liveVM.questionsState) {
            StateInitial() || StateLoading() => const LoadingView(message: 'Đang tải câu hỏi trực tiếp...'),
            StateEmpty(message: final msg) => EmptyView(
                title: 'Chưa có câu hỏi nào',
                message: msg,
              ),
            StateError(error: final err) => Center(
                child: Text(
                  err,
                  style: const TextStyle(color: AppTheme.errorInk),
                ),
              ),
            StateData(data: final questions) => ListView.builder(
                padding: const EdgeInsets.all(AppTheme.spacingScreenPadding),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final q = questions[index];
                  return QuestionCard(
                    question: q,
                    onUpvote: () {
                      liveVM.upvoteQuestion(eventId: widget.ticket.eventId, questionId: q.id);
                    },
                  );
                },
              ),
          },
        ),

        // Bottom Ask Question Input Field or Disabled Notice
        if (!isQAEnabled)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceSubtle,
              border: Border(top: BorderSide(color: AppTheme.hairline, width: 1)),
            ),
            child: const SafeArea(
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: AppTheme.textMuted),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Phiên hỏi đáp trực tiếp (Live Q&A) hiện đang tạm dừng bởi Ban Tổ Chức CTSV.',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            border: Border(
              top: BorderSide(color: AppTheme.hairline, width: 1),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceSubtle,
                      borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                      border: Border.all(color: AppTheme.hairline, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: TextField(
                      controller: _questionController,
                      decoration: const InputDecoration(
                        hintText: 'Đặt câu hỏi trực tiếp cho diễn giả...',
                        hintStyle: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 14, color: AppTheme.onSurface),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.obsidian,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_upward_rounded, size: 20),
                  tooltip: 'Gửi câu hỏi',
                  onPressed: () {
                    if (user != null && _questionController.text.trim().isNotEmpty) {
                      liveVM.askQuestion(
                        eventId: widget.ticket.eventId,
                        user: user,
                        question: _questionController.text,
                      );
                      _questionController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
