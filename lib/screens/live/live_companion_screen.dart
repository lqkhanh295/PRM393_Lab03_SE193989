import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/ticket_model.dart';
import '../../models/screen_state.dart';
import '../../viewmodels/live_event_vm.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/question_card.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/app_button.dart';

/// S21 & S22: Live Event Companion & Speaker Q&A Screen
class LiveCompanionScreen extends StatefulWidget {
  final TicketModel ticket;

  const LiveCompanionScreen({super.key, required this.ticket});

  @override
  State<LiveCompanionScreen> createState() => _LiveCompanionScreenState();
}

class _LiveCompanionScreenState extends State<LiveCompanionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _questionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LiveEventViewModel>().loadLiveQuestions(widget.ticket.eventId);
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
            const Text('Live Companion', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                const Text('ĐANG DIỄN RA TRỰC TIẾP', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.w800)),
              ],
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          indicatorColor: AppTheme.primary,
          tabs: const [
            Tab(icon: Icon(Icons.timeline_rounded), text: 'Lịch trình trực tiếp'),
            Tab(icon: Icon(Icons.question_answer_rounded), text: 'Hỏi đáp diễn giả'),
          ],
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingScreenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Ongoing Session Highlight
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              border: Border.all(color: AppTheme.primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(AppTheme.radiusChip),
                        ),
                        child: const Text(
                          'PHIÊN ĐANG DIỄN RA (14:00 - 15:15)',
                          style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.w800),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.sensors_rounded, color: Colors.red, size: 20),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Keynote: Kỷ nguyên Autonomous Coding Agents & AI Pair Programming',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Diễn giả: TS. Nguyễn Văn Hùng (FPT Software AI Lab)',
                  style: TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant),
                ),
                const SizedBox(height: 14),
                AppOutlinedButton(
                  label: 'Tải Slide Báo Cáo Của Diễn Giả (PDF)',
                  icon: Icons.download_rounded,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đang tải slide tài liệu từ diễn giả...')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Các phiên tiếp theo trong buổi chiều',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _buildNextSessionTile('15:15 - 16:30', 'Workshop: Xây dựng Mobile App với Flutter & Firebase', 'ThS. Trần Thu Hà'),
          _buildNextSessionTile('16:30 - 17:30', 'Hỏi đáp Q&A toàn thể diễn giả & Trao giải', 'Toàn ban tổ chức'),
        ],
      ),
    );
  }

  Widget _buildNextSessionTile(String time, String title, String speaker) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(time, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Text(speaker, style: const TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakerQATab(BuildContext context, LiveEventViewModel liveVM, dynamic user) {
    return Column(
      children: [
        // Question list
        Expanded(
          child: switch (liveVM.questionsState) {
            StateInitial() || StateLoading() => const LoadingView(message: 'Đang tải câu hỏi...'),
            StateEmpty(message: final msg) => EmptyView(message: msg),
            StateError(error: final err) => Center(child: Text(err)),
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

        // Bottom Ask Question Input Field
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(top: BorderSide(color: AppTheme.outlineVariant)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _questionController,
                    decoration: InputDecoration(
                      hintText: 'Đặt câu hỏi trực tiếp cho diễn giả...',
                      filled: true,
                      fillColor: AppTheme.surfaceContainer,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: AppTheme.primary),
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
