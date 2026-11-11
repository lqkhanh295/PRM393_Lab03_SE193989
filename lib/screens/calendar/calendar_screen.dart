import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/event_model.dart';
import '../../models/ticket_model.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/my_tickets_vm.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../events/event_detail_screen.dart';

enum CalendarViewMode { month, week }

/// S25: Campus Calendar Screen (Lịch biểu Campus)
/// Supports Full Month Grid View and 7-day Week View.
/// Dynamically queries real Cloud Firestore events and tickets.
/// Strictly enforces Zero-Mock Data Policy.
class CampusCalendarScreen extends StatefulWidget {
  const CampusCalendarScreen({super.key});

  @override
  State<CampusCalendarScreen> createState() => _CampusCalendarScreenState();
}

class _CampusCalendarScreenState extends State<CampusCalendarScreen> {
  late DateTime _focusedMonth;
  late DateTime _selectedDate;
  CalendarViewMode _viewMode = CalendarViewMode.month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);
    _selectedDate = DateTime(now.year, now.month, now.day);

    // Ensure real Firestore data is loaded if not already in memory
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeVM = context.read<HomeViewModel>();
      if (homeVM.allEvents.isEmpty) {
        homeVM.loadHomeScreenData();
      }
      final authVM = context.read<AuthViewModel>();
      final user = authVM.currentUser;
      if (user != null) {
        context.read<MyTicketsViewModel>().loadUserTickets(user.id);
      }
    });
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

  /// Bulletproof event date parser supporting DD/MM/YYYY, YYYY-MM-DD, and ISO strings
  DateTime? _parseEventDate(String dateStr) {
    try {
      final trimmed = dateStr.trim();
      if (trimmed.contains('/')) {
        final parts = trimmed.split('/');
        if (parts.length == 3) {
          final p0 = int.parse(parts[0]);
          final p1 = int.parse(parts[1]);
          final p2 = int.parse(parts[2]);
          if (p0 > 1000) {
            return DateTime(p0, p1, p2);
          } else {
            return DateTime(p2, p1, p0);
          }
        }
      }
      if (trimmed.contains('-')) {
        final parts = trimmed.split('-');
        if (parts.length == 3) {
          final p0 = int.parse(parts[0]);
          final p1 = int.parse(parts[1]);
          final p2 = int.parse(parts[2]);
          if (p0 > 1000) {
            return DateTime(p0, p1, p2);
          } else {
            return DateTime(p2, p1, p0);
          }
        }
      }
      return DateTime.tryParse(trimmed);
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

  /// Get 7 days of the week containing the currently selected date (Monday to Sunday)
  List<DateTime> _getDaysForWeek(DateTime referenceDate) {
    final monday = referenceDate.subtract(Duration(days: referenceDate.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final homeVM = context.watch<HomeViewModel>();
    final ticketsVM = context.watch<MyTicketsViewModel>();

    // 100% Real Cloud Firestore data
    final allEvents = homeVM.allEvents;
    final userTickets = ticketsVM.allTickets;

    // Build matrix for full month
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final totalDaysInMonth = lastDay.day;
    final leadingDays = firstDay.weekday - 1; // 1 = Mon (0 leading)

    final List<DateTime> monthDays = [];
    final prevMonthLastDay = DateTime(_focusedMonth.year, _focusedMonth.month, 0);
    for (int i = leadingDays - 1; i >= 0; i--) {
      monthDays.add(DateTime(_focusedMonth.year, _focusedMonth.month - 1, prevMonthLastDay.day - i));
    }
    for (int i = 1; i <= totalDaysInMonth; i++) {
      monthDays.add(DateTime(_focusedMonth.year, _focusedMonth.month, i));
    }
    final remaining = 7 - (monthDays.length % 7);
    if (remaining < 7) {
      for (int i = 1; i <= remaining; i++) {
        monthDays.add(DateTime(_focusedMonth.year, _focusedMonth.month + 1, i));
      }
    }
    final numWeeks = monthDays.length ~/ 7;

    final weekDays = _getDaysForWeek(_selectedDate);

    // Selected day events
    final selectedDayEvents = _getEventsForDay(_selectedDate, allEvents);
    final isToday = _isSameDay(_selectedDate, DateTime.now());

    // Check if another month has events (for quick navigation hint)
    final eventsInFocusedMonth = allEvents.where((e) {
      final d = _parseEventDate(e.date);
      return d != null && d.year == _focusedMonth.year && d.month == _focusedMonth.month;
    }).length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Lịch biểu Campus'),
        elevation: 0,
        backgroundColor: AppTheme.surface,
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
            // Calendar Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                border: Border.all(color: AppTheme.hairline, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Month navigation row + View Toggle (Tháng / Tuần)
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
                          // View Switcher (Tháng / Tuần)
                          Container(
                            height: 28,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                _buildModeToggle('Tháng', CalendarViewMode.month),
                                _buildModeToggle('Tuần', CalendarViewMode.week),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Nav buttons
                          IconButton(
                            icon: const Icon(Icons.chevron_left_rounded, size: 22),
                            onPressed: _previousMonth,
                            tooltip: 'Tháng trước',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right_rounded, size: 22),
                            onPressed: _nextMonth,
                            tooltip: 'Tháng sau',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1, thickness: 1, color: AppTheme.hairline),
                  const SizedBox(height: 12),

                  // Weekdays header row (T2 -> CN)
                  // The weekday matching currently selected date is dynamically highlighted in primary orange!
                  Row(
                    children: [
                      _buildWeekdayHeader('T2', 1),
                      _buildWeekdayHeader('T3', 2),
                      _buildWeekdayHeader('T4', 3),
                      _buildWeekdayHeader('T5', 4),
                      _buildWeekdayHeader('T6', 5),
                      _buildWeekdayHeader('T7', 6),
                      _buildWeekdayHeader('CN', 7),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Grid: Either Full Month Grid or Single Week Row
                  if (_viewMode == CalendarViewMode.month) ...[
                    // Full Month Grid Rows
                    for (int week = 0; week < numWeeks; week++) ...[
                      Row(
                        children: [
                          for (int col = 0; col < 7; col++) ...[
                            Expanded(
                              child: Builder(
                                builder: (context) {
                                  final day = monthDays[week * 7 + col];
                                  final isCurrentMonth = day.month == _focusedMonth.month;
                                  final isSelected = _isSameDay(day, _selectedDate);
                                  final isDayToday = _isSameDay(day, DateTime.now());
                                  final dayEvents = _getEventsForDay(day, allEvents);
                                  final hasEvent = dayEvents.isNotEmpty;

                                  return _buildDateCell(
                                    day: day,
                                    isCurrentMonth: isCurrentMonth,
                                    isSelected: isSelected,
                                    isToday: isDayToday,
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
                  ] else ...[
                    // Single Week Row (matching original 7-day strip)
                    Row(
                      children: [
                        for (int col = 0; col < 7; col++) ...[
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                final day = weekDays[col];
                                final isCurrentMonth = day.month == _focusedMonth.month;
                                final isSelected = _isSameDay(day, _selectedDate);
                                final isDayToday = _isSameDay(day, DateTime.now());
                                final dayEvents = _getEventsForDay(day, allEvents);
                                final hasEvent = dayEvents.isNotEmpty;

                                return _buildDateCell(
                                  day: day,
                                  isCurrentMonth: isCurrentMonth,
                                  isSelected: isSelected,
                                  isToday: isDayToday,
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
                            'Có sự kiện',
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
                              color: AppTheme.obsidian,
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
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: () {
                          setState(() {
                            final now = DateTime.now();
                            _focusedMonth = DateTime(now.year, now.month, 1);
                            _selectedDate = DateTime(now.year, now.month, now.day);
                          });
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Text(
                            'Hôm nay',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Daily Agenda Header (Matching "LỊCH TRÌNH HÔM NAY · 28/10/2026")
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isToday
                        ? 'LỊCH TRÌNH HÔM NAY · ${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}'
                        : 'LỊCH TRÌNH · ${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
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
                          color: hasTicket ? AppTheme.success.withValues(alpha: 0.5) : AppTheme.hairline,
                          width: hasTicket ? 1.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
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
                              // Top pill row: Time/Location on left, status on right
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
                                          color: event.isPast ? AppTheme.textMuted : (event.isFull ? AppTheme.error : AppTheme.primary),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Title
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

                              // Organizer row
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

                              // Ticket Code row if registered (Matching screenshot's "🎫 Mã vé: CE2026-083291")
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
              // Empty State for days without events (Zero-Mock compliant)
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
                    Text(
                      eventsInFocusedMonth > 0
                          ? 'Tháng ${_focusedMonth.month}/${_focusedMonth.year} có $eventsInFocusedMonth sự kiện. Chạm vào ngày có chấm cam (●) để xem!'
                          : 'Chạm vào các ngày có chấm cam (●) trên lịch để xem lịch trình sự kiện chi tiết!',
                      style: const TextStyle(
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
                          final now = DateTime.now();
                          _focusedMonth = DateTime(now.year, now.month, 1);
                          _selectedDate = DateTime(now.year, now.month, now.day);
                        });
                      },
                      icon: const Icon(Icons.today_rounded, size: 16, color: AppTheme.primary),
                      label: const Text(
                        'Quay về hôm nay',
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

  Widget _buildModeToggle(String label, CalendarViewMode mode) {
    final isActive = _viewMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _viewMode = mode;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
            color: isActive ? AppTheme.primary : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildWeekdayHeader(String label, int weekday) {
    final isSelectedWeekday = _selectedDate.weekday == weekday;
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelectedWeekday ? FontWeight.w800 : FontWeight.w600,
            fontSize: 12,
            color: isSelectedWeekday ? AppTheme.primary : AppTheme.textMuted,
          ),
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
        color: AppTheme.obsidian,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppTheme.obsidian.withValues(alpha: 0.35),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      );
    } else if (hasEvent && isCurrentMonth) {
      // Days with events are distinct and highlighted
      textColor = AppTheme.primary;
      boxDecoration = BoxDecoration(
        color: const Color(0xFFFFF4EB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.65), width: 1.2),
      );
    } else if (isToday && isCurrentMonth) {
      textColor = AppTheme.obsidian;
      boxDecoration = BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.hairline, width: 1.2),
      );
    } else {
      textColor = isCurrentMonth ? AppTheme.onSurface : AppTheme.textSubtle.withValues(alpha: 0.35);
      boxDecoration = const BoxDecoration(
        color: Colors.transparent,
      );
    }

    // Dot indicator for days with events
    Widget indicator;
    if (hasEvent) {
      indicator = Container(
        width: 5,
        height: 5,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.primary,
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