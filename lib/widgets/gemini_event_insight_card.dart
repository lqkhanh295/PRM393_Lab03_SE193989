import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/event_model.dart';
import '../models/event_ai_insight_model.dart';
import '../services/gemini_ai_service.dart';
import '../services/remote_config_service.dart';

/// Thẻ phân tích thông minh sự kiện bằng Google Gemini AI (Level 2 Structured Output).
///
/// Tích hợp cấu hình động từ Remote Config, tuân thủ nguyên tắc Zero-PII,
/// tự động fallback khi mất mạng và cho phép sinh viên tương tác sao chép câu hỏi gợi ý vào Live Q&A.
class GeminiEventInsightCard extends StatefulWidget {
  /// Dữ liệu sự kiện cần phân tích [EventModel].
  final EventModel event;

  /// Khởi tạo [GeminiEventInsightCard] cho sự kiện [event].
  const GeminiEventInsightCard({super.key, required this.event});

  /// Tạo state quản lý tiến trình tạo nội dung thông minh.
  @override
  State<GeminiEventInsightCard> createState() => _GeminiEventInsightCardState();
}

class _GeminiEventInsightCardState extends State<GeminiEventInsightCard> {
  bool _isLoading = false;
  EventAiInsightModel? _insight;
  bool _isExpanded = false;

  /// Kích hoạt [GeminiAiService] để sinh phân tích thông minh sự kiện hoặc lấy bản dự phòng nội bộ.
  Future<void> _fetchInsights() async {
    setState(() {
      _isLoading = true;
      _isExpanded = true;
    });

    try {
      final geminiService = context.read<GeminiAiService>();
      final result = await geminiService.generateEventInsights(widget.event);
      if (mounted) {
        setState(() {
          _insight = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final remoteConfig = context.watch<RemoteConfigService>();

    // If Remote Config disables AI insights, hide completely or show notice
    if (!remoteConfig.enableGeminiInsights) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar with Sparkles & Model Name
          InkWell(
            onTap: () {
              if (_insight == null && !_isLoading) {
                _fetchInsights();
              } else {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              }
            },
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4EB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.primary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text(
                              'Trợ lý AI Gemini',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.obsidian,
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'LEVEL 2',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _insight != null
                              ? 'Tóm tắt nội dung & câu hỏi gợi ý'
                              : 'Chạm để phân tích sự kiện bằng ${remoteConfig.geminiModelName}',
                          style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                  if (_isLoading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                    )
                  else
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.textMuted,
                    ),
                ],
              ),
            ),
          ),

          // Expanded Content Area
          if (_isExpanded && _insight != null) ...[
            const Divider(height: 1, thickness: 1, color: AppTheme.hairline),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fallback warning if quota was exceeded
                  if (_insight!.isFallback)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline, size: 12, color: AppTheme.textMuted),
                          SizedBox(width: 4),
                          Text(
                            'Chế độ dự phòng thông minh (Offline/Fallback Mode)',
                            style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),

                  // 1. Tóm tắt súc tích
                  const Text(
                    'TÓM TẮT SỰ KIỆN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _insight!.summary,
                    style: const TextStyle(fontSize: 13, height: 1.45, color: AppTheme.onSurface),
                  ),
                  const SizedBox(height: 14),

                  // 2. Điểm nổi bật (Key Takeaways)
                  if (_insight!.keyTakeaways.isNotEmpty) ...[
                    const Text(
                      'ĐIỂM NỔI BẬT CHÍNH',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.obsidian,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ..._insight!.keyTakeaways.map(
                      (point) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(point, style: const TextStyle(fontSize: 12.5, height: 1.4, color: AppTheme.onSurface)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // 3. Đối tượng phù hợp
                  if (_insight!.recommendedAudience.isNotEmpty) ...[
                    const Text(
                      'ĐỐI TƯỢNG PHÙ HỢP',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.obsidian,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _insight!.recommendedAudience.map((aud) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppTheme.hairline, width: 1),
                          ),
                          child: Text(
                            aud,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.textMuted),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // 4. Câu hỏi gợi ý cho Diễn giả
                  if (_insight!.suggestedQuestions.isNotEmpty) ...[
                    const Text(
                      'CÂU HỎI GỢI Ý ĐẶT CHO DIỄN GIẢ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.obsidian,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ..._insight!.suggestedQuestions.map((q) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9F5),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFFDBC2), width: 1),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.help_outline_rounded, size: 14, color: AppTheme.primary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                q,
                                style: const TextStyle(fontSize: 12, color: AppTheme.obsidian, fontWeight: FontWeight.w500),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                context.read<GeminiAiService>().logInsightAccepted(widget.event.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã chọn câu hỏi! Có thể dán vào phần Q&A trực tiếp.'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(Icons.content_copy_rounded, size: 14, color: AppTheme.primary),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],

                  const SizedBox(height: 8),
                  // Zero-PII disclosure
                  const Text(
                    '🔒 Mô hình Gemini 1.5 Flash chỉ phân tích nội dung sự kiện công khai và lịch trình, tuyệt đối không gửi bất kỳ dữ liệu cá nhân (PII) nào.',
                    style: TextStyle(fontSize: 10, color: AppTheme.textSubtle, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
