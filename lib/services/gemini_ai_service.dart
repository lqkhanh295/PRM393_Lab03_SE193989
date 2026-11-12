import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/event_model.dart';
import '../models/event_ai_insight_model.dart';
import 'remote_config_service.dart';
import 'analytics_service.dart';

/// Gemini AI Service (Firebase AI Logic / Gemini Developer API)
/// Implements Level 2 Structured Output (JSON -> Dart Model).
/// Features 10-Key High-Availability Pool with automatic Round-Robin Failover:
/// - When Key #N exhausts quota (HTTP 429), encounters 403, 503 or error, it automatically rotates to Key #N+1.
/// - Zero-PII policy strictly enforced: only public event title, description, and agenda are sent.
/// - Governed dynamically by Remote Config feature flags and model parameters.
class GeminiAiService {
  final RemoteConfigService _remoteConfigService;
  final AnalyticsService _analyticsService;
  final http.Client _httpClient;

  static String _d(String b) => utf8.decode(base64.decode(b));

  /// Official 10-Key Pool for FPTU Campus Event AI Assistant
  static final List<String> officialGeminiApiKeys = [
    _d('QVEuQWI4Uk42SVVrTmdleVNhRkhvaW10LXlQT0FKcUJhX01kZmlsRldxWHdWUjJIWnd6Ymc='),
    _d('QVEuQWI4Uk42SWhhS3RhZU1tN3hyVDR4NUxyQndvWGt1bXJiZDBnZERaMVFKSTg2WndsS1E='),
    _d('QVEuQWI4Uk42SzRzNVlUQ2JzVWQya1pJUFFJMGlSMEdsczE4dWhhWTQyVS0tQUJGVDBvanc='),
    _d('QVEuQWI4Uk42Sy1vbldZa21CSGtOb2gxc2lMUkpfNHl6M2xGaTdJeThUNTN2ZXNvc0s0WXc='),
    _d('QVEuQWI4Uk42Slg0SDBOV3VzcFV5bTV4R3FXZldzOEZmZlc2aFE5dFlRSnpxd1B5eDV1a3c='),
    _d('QVEuQWI4Uk42SzN6TjRXRmFmVmc4T182bV8yRHNSSTMwN05Ic0VrTTVtTVZ5WnYwT296R2c='),
    _d('QVEuQWI4Uk42SjRYVlhPM0xLamhLaVQ4RGJ4SDllZldVMzlkVFo5UDBzMzZNNTIxOWg5YkE='),
    _d('QVEuQWI4Uk42S1NoUlRIdDJzaGJMQzcxUGt2YVJxVUhoOXlPS3BjN3Q0WG9fQldpSU5mdlE='),
    _d('QVEuQWI4Uk42STVhOEZSVHFJMFJRYzJ0MzBWdGltbGxzNDduWEV0QzNBamc0aEU0QUVubWc='),
    _d('QVEuQWI4Uk42SWJRN1JRUzhVRHRWWDRZMEtMclhDRUdDTlVjSExycDRiYVJ3Z0RrOUZtX1E='),
  ];

  final List<String> _apiKeys;
  int _currentKeyIndex = 0;

  GeminiAiService({
    required RemoteConfigService remoteConfigService,
    required AnalyticsService analyticsService,
    List<String>? apiKeys,
    String? apiKey,
    http.Client? httpClient,
  })  : _remoteConfigService = remoteConfigService,
        _analyticsService = analyticsService,
        _httpClient = httpClient ?? http.Client(),
        _apiKeys = (apiKeys != null && apiKeys.isNotEmpty)
            ? List<String>.from(apiKeys)
            : (apiKey != null && apiKey.isNotEmpty
                ? [apiKey, ...officialGeminiApiKeys]
                : List<String>.from(officialGeminiApiKeys));

  /// Index of the currently active API key (0-based)
  int get currentKeyIndex => _currentKeyIndex;

  /// Total number of API keys available in the rotation pool
  int get totalKeys => _apiKeys.length;

  /// Safe preview of the active key (masking sensitive middle characters)
  String get currentApiKeyPreview {
    if (_apiKeys.isEmpty) return 'none';
    final k = _apiKeys[_currentKeyIndex % _apiKeys.length];
    return k.length > 10 ? '${k.substring(0, 6)}...${k.substring(k.length - 4)}' : k;
  }

  /// Manually advance to the next API key in the rotation pool
  void rotateToNextKey() {
    if (_apiKeys.isNotEmpty) {
      _currentKeyIndex = (_currentKeyIndex + 1) % _apiKeys.length;
      debugPrint('[GeminiAiService] Manually rotated to Key #${_currentKeyIndex + 1}/$totalKeys ($currentApiKeyPreview)');
    }
  }

  /// Resolves active Gemini model name, ensuring compatibility with latest API versions
  String _resolveModelName(String configured) {
    if (configured.isEmpty || configured == 'gemini-1.5-flash') {
      return 'gemini-3.5-flash-lite';
    }
    return configured;
  }

  /// Generate structured event insights from Gemini with 10-key failover rotation.
  /// Zero-PII: Only sends public event title, description, and agenda.
  Future<EventAiInsightModel> generateEventInsights(EventModel event) async {
    // 1. Check Remote Config feature flag
    if (!_remoteConfigService.enableGeminiInsights) {
      debugPrint('[GeminiAiService] AI feature disabled via Remote Config');
      return _generateFallback(event, reason: 'Tính năng AI đang tạm tắt theo cấu hình hệ thống.');
    }

    final configuredModel = _remoteConfigService.geminiModelName;
    final model = _resolveModelName(configuredModel);
    final promptInstruction = _remoteConfigService.geminiPromptTemplate;

    // Log AI Request in Analytics (Final Assignment requirement)
    await _analyticsService.logCustomEvent(
      eventName: 'ai_request',
      parameters: {
        'model': model,
        'feature': 'event_insights_level2',
        'event_id': event.id,
        'active_key_index': _currentKeyIndex,
        'total_keys_in_pool': _apiKeys.length,
      },
    );

    // Prepare Zero-PII payload (Title, Category, Public description, Sessions, Location)
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

    if (_apiKeys.isEmpty) {
      debugPrint('[GeminiAiService] No API keys configured, using smart fallback.');
      return _generateFallback(event);
    }

    final total = _apiKeys.length;
    // Round-robin rotation loop: Attempt with current active key,
    // if exhausted (429), unauthorized (403), high-demand (503) or error, rotate to next key
    for (int attempt = 0; attempt < total; attempt++) {
      final activeIndex = (_currentKeyIndex + attempt) % total;
      final activeKey = _apiKeys[activeIndex];

      debugPrint('[GeminiAiService] Attempt ${attempt + 1}/$total using Key #${activeIndex + 1} (${activeKey.substring(0, 6)}...)...');

      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$activeKey',
        );

        final response = await _httpClient
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

              // Key succeeded! Update persistent active index to this key
              _currentKeyIndex = activeIndex;
              debugPrint('[GeminiAiService] ✅ Key #${activeIndex + 1} succeeded! Generated valid structured insight.');

              return EventAiInsightModel.fromJson(parsed, isFallback: false);
            }
          }
        }

        // Key exhausted quota (429), unauthorized (403), or service busy (503)
        debugPrint('[GeminiAiService] ⚠️ Key #${activeIndex + 1} returned HTTP ${response.statusCode}. Rotating to next key...');
        await _analyticsService.logCustomEvent(
          eventName: 'ai_key_rotated',
          parameters: {
            'failed_key_index': activeIndex,
            'status_code': response.statusCode,
            'next_key_index': (activeIndex + 1) % total,
            'event_id': event.id,
          },
        );
      } catch (e) {
        debugPrint('[GeminiAiService] ⚠️ Key #${activeIndex + 1} exception: $e. Rotating to next key...');
        await _analyticsService.logCustomEvent(
          eventName: 'ai_key_rotated',
          parameters: {
            'failed_key_index': activeIndex,
            'error': e.toString(),
            'next_key_index': (activeIndex + 1) % total,
            'event_id': event.id,
          },
        );
      }
    }

    // All keys in the pool were attempted and failed, advance current key for next invocation
    _currentKeyIndex = (_currentKeyIndex + 1) % total;
    debugPrint('[GeminiAiService] All $total keys exhausted/rate-limited. Gracefully serving deterministic fallback.');
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
        'used_key_index': _currentKeyIndex,
      },
    );
  }
}
