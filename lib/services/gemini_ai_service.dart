import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/event_model.dart';
import '../models/event_ai_insight_model.dart';
import 'remote_config_service.dart';
import 'analytics_service.dart';

/// Gemini AI Service (Firebase AI Logic / Gemini Developer API)
/// Implements Level 2 Structured Output (JSON -> Dart Model).
/// Governed by Remote Config flags and zero-PII policy.
class GeminiAiService {
  final RemoteConfigService _remoteConfigService;
  final AnalyticsService _analyticsService;
  final String? _apiKey;

  GeminiAiService({
    required RemoteConfigService remoteConfigService,
    required AnalyticsService analyticsService,
    String? apiKey,
  })  : _remoteConfigService = remoteConfigService,
        _analyticsService = analyticsService,
        _apiKey = apiKey;

  /// Generate structured event insights from Gemini
  /// Zero-PII: Only sends public event title, description, and agenda.
  Future<EventAiInsightModel> generateEventInsights(EventModel event) async {
    // 1. Check Remote Config feature flag
    if (!_remoteConfigService.enableGeminiInsights) {
      debugPrint('[GeminiAiService] AI feature disabled via Remote Config');
      return _generateFallback(event, reason: 'Tính năng AI đang tạm tắt theo cấu hình hệ thống.');
    }

    final model = _remoteConfigService.geminiModelName;
    final promptInstruction = _remoteConfigService.geminiPromptTemplate;

    // Log AI Request in Analytics (Final Assignment requirement)
    await _analyticsService.logCustomEvent(
      eventName: 'ai_request',
      parameters: {
        'model': model,
        'feature': 'event_insights_level2',
        'event_id': event.id,
      },
    );

    // Prepare Zero-PII payload
    final sanitizedAgenda = event.sessions.map((s) => '${s.time}: ${s.title}').join('; ');
    final userPrompt = '''
$promptInstruction

Thông tin sự kiện (Công khai):
- Tiêu đề: ${event.title}
- Thể loại: ${event.category}
- Mô tả: ${event.description}
- Lịch trình: $sanitizedAgenda
- Địa điểm: ${event.location}

Yêu cầu trả về đúng định dạng JSON thuần túy (không markdown) với cấu trúc:
{
  "summary": "Đoạn tóm tắt súc tích trong 2-3 câu về giá trị chính của sự kiện",
  "keyTakeaways": ["Giá trị 1", "Giá trị 2", "Giá trị 3"],
  "recommendedAudience": ["Sinh viên chuyên ngành X", "Những ai quan tâm Y"],
  "suggestedQuestions": ["Câu hỏi 1 cho diễn giả?", "Câu hỏi 2 cho diễn giả?"]
}
''';

    // 2. Call Gemini API if API key is present
    final apiKey = _apiKey ?? const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    if (apiKey.isNotEmpty) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
        );

        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': [
                  {
                    'parts': [
                      {'text': userPrompt}
                    ]
                  }
                ],
                'generationConfig': {
                  'responseMimeType': 'application/json',
                  'temperature': 0.3,
                },
              }),
            )
            .timeout(const Duration(seconds: 12));

        if (response.statusCode == 200) {
          final resJson = jsonDecode(response.body) as Map<String, dynamic>;
          final candidates = resJson['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final content = candidates[0]['content'];
            final parts = content['parts'] as List?;
            if (parts != null && parts.isNotEmpty) {
              final rawText = parts[0]['text'] as String;
              final parsed = jsonDecode(rawText) as Map<String, dynamic>;
              return EventAiInsightModel.fromJson(parsed, isFallback: false);
            }
          }
        } else {
          debugPrint('[GeminiAiService] API error code: ${response.statusCode}');
          await _analyticsService.logCustomEvent(
            eventName: 'ai_error',
            parameters: {
              'error_code': response.statusCode.toString(),
              'event_id': event.id,
            },
          );
        }
      } catch (e) {
        debugPrint('[GeminiAiService] Request exception: $e');
        await _analyticsService.logCustomEvent(
          eventName: 'ai_error',
          parameters: {
            'error_type': e.runtimeType.toString(),
            'event_id': event.id,
          },
        );
      }
    }

    // 3. Graceful Fallback (Final Assignment requirement: handle quota / network errors without app failure)
    return _generateFallback(event);
  }

  /// High-fidelity deterministic fallback generating structured model
  EventAiInsightModel _generateFallback(EventModel event, {String? reason}) {
    final cat = event.category.toLowerCase();
    final isTech = cat.contains('tech') || cat.contains('công nghệ');

    return EventAiInsightModel(
      summary: reason ??
          'Sự kiện "${event.title}" do ${event.clubName} tổ chức nhằm cung cấp kiến thức thực chiến và kết nối cộng đồng sinh viên FPTU.',
      keyTakeaways: isTech
          ? [
              'Nắm bắt xu hướng kiến trúc phần mềm và trí tuệ nhân tạo thế hệ mới.',
              'Giao lưu và giải đáp thắc mắc trực tiếp cùng các chuyên gia trong ngành.',
              'Nhận chứng nhận điện tử và tích lũy điểm rèn luyện chính thức tại FPTU.',
            ]
          : [
              'Phát triển kỹ năng mềm và mở rộng mạng lưới quan hệ trong trường.',
              'Trải nghiệm không gian tương tác sôi nổi và các hoạt động thực tế.',
              'Nhận điểm rèn luyện phong trào sinh viên theo quy chế nhà trường.',
            ],
      recommendedAudience: isTech
          ? [
              'Sinh viên khối ngành Kỹ thuật Phần mềm (SE), An toàn Thông tin (IA), AI.',
              'Thành viên các câu lạc bộ công nghệ FPT University.',
            ]
          : [
              'Toàn thể sinh viên Đại học FPT TP.HCM mong muốn phát triển bản thân.',
              'Sinh viên cần tích lũy điểm rèn luyện trong học kỳ.',
            ],
      suggestedQuestions: [
        'Diễn giả có thể chia sẻ lộ trình phát triển kỹ năng và cơ hội thực tập cho sinh viên năm 3-4 không?',
        'Các chứng chỉ và kỹ năng nào được doanh nghiệp đánh giá cao nhất hiện nay?',
      ],
      isFallback: true,
    );
  }

  /// Log user acceptance when insights are confirmed/used
  Future<void> logInsightAccepted(String eventId) async {
    await _analyticsService.logCustomEvent(
      eventName: 'ai_result_accepted',
      parameters: {
        'feature': 'event_insights_level2',
        'event_id': eventId,
      },
    );
  }
}
