import 'package:flutter/foundation.dart';
import '../models/screen_state.dart';
import '../models/speaker_question_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/analytics_service.dart';

/// MVVM LiveEventViewModel
/// Coordinates the In-Event Live Companion experience, Realtime Agenda, and Speaker Q&A stream.
class LiveEventViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final AnalyticsService _analyticsService;

  ScreenState<List<SpeakerQuestionModel>> _questionsState = const StateInitial();
  ScreenState<List<SpeakerQuestionModel>> get questionsState => _questionsState;

  final int _currentSessionIndex = 1; // 2nd session is currently active
  int get currentSessionIndex => _currentSessionIndex;

  LiveEventViewModel({
    required FirestoreService firestoreService,
    required AnalyticsService analyticsService,
  })  : _firestoreService = firestoreService,
        _analyticsService = analyticsService;

  Future<void> loadLiveQuestions(String eventId) async {
    _questionsState = const StateLoading('Đang tải câu hỏi trực tiếp...');
    notifyListeners();

    try {
      final list = await _firestoreService.getSpeakerQuestions(eventId);
      if (list.isEmpty) {
        _questionsState = const StateEmpty('Chưa có câu hỏi nào. Hãy là người đầu tiên đặt câu hỏi!');
      } else {
        _questionsState = StateData(list);
      }
      notifyListeners();
    } catch (e) {
      _questionsState = StateError('Lỗi tải câu hỏi: $e');
      notifyListeners();
    }
  }

  Future<void> askQuestion({
    required String eventId,
    required UserModel user,
    required String question,
  }) async {
    if (question.trim().isEmpty) return;

    try {
      await _firestoreService.askSpeakerQuestion(
        eventId: eventId,
        user: user,
        question: question.trim(),
      );
      await _analyticsService.logLiveInteract(
        eventId: eventId,
        actionType: 'ask',
        length: question.length,
      );
      await loadLiveQuestions(eventId);
    } catch (e) {
      debugPrint('[LiveEventViewModel] Error asking question: $e');
    }
  }

  Future<void> upvoteQuestion({
    required String eventId,
    required String questionId,
  }) async {
    try {
      await _firestoreService.upvoteSpeakerQuestion(eventId, questionId);
      await _analyticsService.logLiveInteract(
        eventId: eventId,
        actionType: 'upvote',
        length: 0,
      );
      await loadLiveQuestions(eventId);
    } catch (e) {
      debugPrint('[LiveEventViewModel] Error upvoting question: $e');
    }
  }
}
