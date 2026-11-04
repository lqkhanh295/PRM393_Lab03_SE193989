import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/event_model.dart';
import '../../models/ticket_model.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/my_tickets_vm.dart';
import '../events/event_detail_screen.dart';

/// S25: Campus Calendar Screen
/// Full Monthly Interactive Calendar with event day markers and daily agenda.
class CampusCalendarScreen extends StatefulWidget {
  const CampusCalendarScreen({super.key});

  @override
  State<CampusCalendarScreen> createState() => _CampusCalendarScreenState();
}

class _CampusCalendarScreenState extends State<CampusCalendarScreen> {
  // Focus defaults to October 2026 (Semester FA26 demo period)
  late DateTime _focusedMonth;
  late DateTime _selectedDate;

  // Fallback demo events to guarantee calendar highlights across months
  static final List<EventModel> _demoCampusEvents = [
    const EventModel(
      id: 'EVT-2026-01',
      title: 'FPTU Tech Expo 2026: Trí tuệ Nhân tạo & Tương lai',
      description: 'Triển lãm công nghệ quy mô 500 sinh viên tại Đại học FPT TP.HCM. Cập nhật xu hướng AI, Generative Agents và cơ hội nghề nghiệp.',
      category: 'Công nghệ',
      clubId: 'fcode',
      clubName: 'CLB F-Code',
      date: '28/10/2026',
      time: '13:30 - 17:30',
      location: 'Hội trường Trịnh Công Sơn',
      capacity: 400,
      registeredCount: 342,
      bannerUrl: 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=800',
      isFeatured: true,
    ),
    const EventModel(
      id: 'EVT-2026-02',
      title: 'Workshop: Thiết kế UI/UX Chuẩn Công Thái Học Di Động',
      description: 'Khám phá bí quyết thiết kế UI/UX theo 10 Heuristics của Jakob Nielsen, tối ưu Touch Target và đo lường tương phản WCAG 2.1 AA.',
      category: 'Thiết kế',
      clubId: 'media_club',
      clubName: 'CLB Cóc Sài Gòn',
      date: '30/10/2026',
      time: '09:00 - 11:30',
      location: 'Phòng Hội thảo Alpha Building (Phòng 301)',
      capacity: 120,
      registeredCount: 94,
      bannerUrl: 'https://images.unsplash.com/photo-1581291518857-4e27b48ff24e?w=800',
      isFeatured: true,
    ),
    const EventModel(
      id: 'EVT-2026-03',
      title: 'Giải Đấu Thể Thao Điện Tử FPTU Champions League',
      description: 'Vòng chung kết giải thể thao điện tử sinh viên toàn trường, phát sóng trực tiếp kèm quà tặng áo đấu độc quyền FPTU.',
      category: 'Giải trí',
      clubId: 'fcode',
      clubName: 'CLB F-Code',
      date: '02/11/2026',
      time: '18:00 - 21:30',
      location: 'Sân khấu Hội trường Lớn A2',
      capacity: 300,
      registeredCount: 288,
      bannerUrl: 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=800',
      isFeatured: false,
    ),
    const EventModel(
      id: 'EVT-2026-04',
      title: 'Tech Talk: An toàn Thông tin & Thực chiến Pentest',
      description: 'Chuyên đề bảo mật ứng dụng di động, phân tích lỗ hổng và phương pháp phòng thủ an ninh mạng.',
      category: 'Bảo mật',
      clubId: 'fcode',
      clubName: 'CLB An toàn Thông tin',
      date: '05/11/2026',
      time: '14:00 - 16:30',
      location: 'Hội trường Trịnh Công Sơn',
      capacity: 250,
      registeredCount: 210,
      bannerUrl: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=800',
      isFeatured: true,
    ),
    const EventModel(
      id: 'EVT-2026-05',
      title: 'Ngày hội Văn hóa Nhật Bản (Japan Cultural Day)',
      description: 'Giao lưu văn hóa, ẩm thực, workshop tiếng Nhật và cơ hội thực tập tại doanh nghiệp Tokyo.',
      category: 'Văn hóa',
      clubId: 'jsclub',
      clubName: 'CLB Kỹ sư phần mềm Nhật Bản',
      date: '15/11/2026',
      time: '08:30 - 16:00',
      location: 'Sảnh Tòa nhà Innovation',
      capacity: 500,
      registeredCount: 420,
      bannerUrl: 'https://images.unsplash.com/photo-1528164344705-475426879c0d?w=800',
      isFeatured: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(2026, 10, 1);
    _selectedDate = DateTime(2026, 10, 28);
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  DateTime? _parseEventDate(String dateStr) {
    try {
      final parts = dateStr.trim().split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (_) {}
    return null;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<EventModel> _getEventsForDay(DateTime day, List<EventModel> allEvents) {
    return allEvents.where((evt) {
      final evtDate = _parseEventDate(evt.date);
      if (evtDate != null) {
        return _isSameDay(evtDate, day);
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final homeVM = context.watch<HomeViewModel>();
    final ticketsVM = context.watch<MyTicketsViewModel>();

    // Merge events from HomeViewModel and fallback demo events
    final Map<String, EventModel> eventMap = {};
    for (final e in _demoCampusEvents) {
      eventMap[e.id] = e;
    }
    for (final e in homeVM.allEvents) {
      eventMap[e.id] = e;
    }
    final allEvents = eventMap.values.toList();
    final userTickets = ticketsVM.allTickets;

    // Build days matrix for the full month
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final totalDaysInMonth = lastDay.day;
    final leadingDays = firstDay.weekday - 1; // 1 = Monday (0 leading), 7 = Sunday (6 leading)

    final List<DateTime> allDays = [];
    final prevMonthLastDay = DateTime(_focusedMonth.year, _focusedMonth.month, 0);
    for (int i = leadingDays - 1; i >= 0; i--) {
      allDays.add(DateTime(_focusedMonth.year, _focusedMonth.month - 1, prevMonthLastDay.day - i));
    }
    for (int i = 1; i <= totalDaysInMonth; i++) {
      allDays.add(DateTime(_focusedMonth.year, _focusedMonth.month, i));
    }
    final remaining = 7 - (allDays.length % 7);
    if (remaining < 7) {
      for (int i = 1; i <= remaining; i++) {
        allDays.add(DateTime(_focusedMonth.year, _focusedMonth.month + 1, i));
      }
    }
    final numWeeks = allDays.length ~/ 7;

    // Events happening on currently selected day
    final selectedDayEvents = _getEventsForDay(_selectedDate, allEvents);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Lịch biểu Campus'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppTheme.hairline),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingScreenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar Month Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                border: Border.all(color: AppTheme.hairline, width: 1),
              ),
              child: Column(
                children: [
                  // Month navigation row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tháng ${_focusedMonth.month}, ${_focusedMonth.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.obsidian,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left_rounded, size: 22),
                            onPressed: _previousMonth,
                            tooltip: 'Tháng trước',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.chevron_right_rounded, size: 22),
                            onPressed: _nextMonth,
                            tooltip: 'Tháng sau',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1, thickness: 1, color: AppTheme.hairline),
                  const SizedBox(height: 12),

                  // Weekdays header row (T2 -> CN)
                  Row(
                    children: const [
                      Expanded(child: Center(child: Text('T2', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.textMuted)))),
                      Expanded(child: Center(child: Text('T3', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.textMuted)))),
                      Expanded(child: Center(child: Text('T4', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.primary)))),
                      Expanded(child: Center(child: Text('T5', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.textMuted)))),
                      Expanded(child: Center(child: Text('T6', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.textMuted)))),
                      Expanded(child: Center(child: Text('T7', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.textMuted)))),
                      Expanded(child: Center(child: Text('CN', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.textMuted)))),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Full Month Grid Rows
                  for (int week = 0; week < numWeeks; week++) ...[
                    Row(
                      children: [
                        for (int col = 0; col < 7; col++) ...[
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                final day = allDays[week * 7 + col];
                                final isCurrentMonth = day.month == _focusedMonth.month;
                                final isSelected = _isSameDay(day, _selectedDate);
                                final isToday = _isSameDay(day, DateTime.now()) || _isSameDay(day, DateTime(2026, 10, 28));
                                final dayEvents = _getEventsForDay(day, allEvents);
                                final hasEvent = dayEvents.isNotEmpty;

                                return _buildDateCell(
                                  day: day,
                                  isCurrentMonth: isCurrentMonth,
                                  isSelected: isSelected,
                                  isToday: isToday,
                                  hasEvent: hasEvent,
                                  eventCount: dayEvents.length,
                                  onTap: () {
                                    setState(() {
                                      _selectedDate = day;
                                      if (!isCurrentMonth) {
                                        _focusedMonth = DateTime(day.year, day.month, 1);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (week < numWeeks - 1) const SizedBox(height: 6),
                  ],

                  const SizedBox(height: 14),
                  const Divider(height: 1, thickness: 1, color: AppTheme.hairline),
                  const SizedBox(height: 10),

                  // Legend / Chú thích trực quan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF4EB),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppTheme.primary, width: 1),
                            ),
                            child: Center(
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: AppTheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Ngày có sự kiện',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Đang chọn',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Daily Agenda Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'LỊCH TRÌNH · ${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: selectedDayEvents.isNotEmpty ? const Color(0xFFFFF4EB) : AppTheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    selectedDayEvents.isNotEmpty ? '${selectedDayEvents.length} sự kiện' : '0 sự kiện',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: selectedDayEvents.isNotEmpty ? AppTheme.primary : AppTheme.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Daily Agenda Content List
            if (selectedDayEvents.isNotEmpty) ...[
              for (final event in selectedDayEvents) ...[
                Builder(
                  builder: (context) {
                    final ticket = userTickets.cast<TicketModel?>().firstWhere(
                          (t) => t?.eventId == event.id,
                          orElse: () => null,
                        );
                    final hasTicket = ticket != null;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                        border: Border.all(
                          color: hasTicket ? AppTheme.success.withOpacity(0.5) : AppTheme.hairline,
                          width: hasTicket ? 1.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EventDetailScreen(eventId: event.id),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${event.time} · ${event.location}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.onPrimaryContainer,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (hasTicket)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppTheme.successSoft,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle_rounded, size: 11, color: AppTheme.successInk),
                                          SizedBox(width: 3),
                                          Text(
                                            'ĐÃ CÓ VÉ',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: AppTheme.successInk,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppTheme.surfaceContainer,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        event.isFull ? 'HẾT VÉ' : 'CÒN ${event.spotsRemaining} CHỖ',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: event.isFull ? AppTheme.error : AppTheme.primary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                event.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.onSurface,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.people_outline_rounded, size: 13, color: AppTheme.textMuted),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Tổ chức bởi: ${event.clubName} (${event.category})',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textMuted,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded, size: 16, color: AppTheme.textMuted),
                                ],
                              ),
                              if (hasTicket && ticket.id.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceContainer,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.confirmation_number_outlined, size: 12, color: AppTheme.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Mã vé: ${ticket.id}',
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.primary,
                                          letterSpacing: 0.3,
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
                    );
                  },
                ),
              ],
            ] else ...[
              // Empty State for days without events
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                  border: Border.all(color: AppTheme.hairline, width: 1),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppTheme.surfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.calendar_today_outlined, color: AppTheme.textMuted, size: 22),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Không có sự kiện vào ngày ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.obsidian,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Chạm vào các ngày có chấm cam (●) trên lịch để xem lịch trình sự kiện chi tiết!',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _focusedMonth = DateTime(2026, 10, 1);
                          _selectedDate = DateTime(2026, 10, 28);
                        });
                      },
                      icon: const Icon(Icons.stars_rounded, size: 16, color: AppTheme.primary),
                      label: const Text(
                        'Xem sự kiện Tech Expo (28/10)',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primary, width: 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDateCell({
    required DateTime day,
    required bool isCurrentMonth,
    required bool isSelected,
    required bool isToday,
    required bool hasEvent,
    required int eventCount,
    required VoidCallback onTap,
  }) {
    final Color textColor;
    final BoxDecoration boxDecoration;

    if (isSelected) {
      textColor = Colors.white;
      boxDecoration = BoxDecoration(
        color: hasEvent ? AppTheme.primary : AppTheme.obsidian,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: (hasEvent ? AppTheme.primary : AppTheme.obsidian).withOpacity(0.35),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      );
    } else if (hasEvent && isCurrentMonth) {
      // Days with events are clearly distinguished!
      textColor = AppTheme.primary;
      boxDecoration = BoxDecoration(
        color: const Color(0xFFFFF4EB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primary.withOpacity(0.65), width: 1.2),
      );
    } else if (isToday && isCurrentMonth) {
      textColor = AppTheme.obsidian;
      boxDecoration = BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.hairline, width: 1.2),
      );
    } else {
      textColor = isCurrentMonth ? AppTheme.onSurface : AppTheme.textSubtle.withOpacity(0.35);
      boxDecoration = const BoxDecoration(
        color: Colors.transparent,
      );
    }

    Widget indicator;
    if (hasEvent) {
      indicator = Container(
        width: 5,
        height: 5,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : AppTheme.primary,
          shape: BoxShape.circle,
        ),
      );
    } else {
      indicator = const SizedBox(height: 5);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 44,
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
        decoration: boxDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 13,
                fontFeatures: const [FontFeature.tabularFigures()],
                fontWeight: isSelected || (hasEvent && isCurrentMonth)
                    ? FontWeight.w800
                    : FontWeight.w500,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            indicator,
          ],
        ),
      ),
    );
  }
}
