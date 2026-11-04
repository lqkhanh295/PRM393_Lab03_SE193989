class SpeakerQuestionModel {
  final String id;
  final String eventId;
  final String userId;
  final String studentName;
  final String question;
  final int upvotes;
  final DateTime timestamp;
  final bool isAnswered;

  const SpeakerQuestionModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.studentName,
    required this.question,
    required this.upvotes,
    required this.timestamp,
    this.isAnswered = false,
  });

  factory SpeakerQuestionModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime resolveDate(dynamic val, dynamic fallback) {
      if (val is DateTime) return val;
      if (val != null && val.runtimeType.toString() == 'Timestamp') {
        try {
          return (val as dynamic).toDate() as DateTime;
        } catch (_) {}
      }
      if (fallback != null && fallback.runtimeType.toString() == 'Timestamp') {
        try {
          return (fallback as dynamic).toDate() as DateTime;
        } catch (_) {}
      }
      if (val != null) {
        final parsed = DateTime.tryParse(val.toString());
        if (parsed != null) return parsed;
      }
      if (fallback != null) {
        final parsed = DateTime.tryParse(fallback.toString());
        if (parsed != null) return parsed;
      }
      return DateTime.now();
    }

    return SpeakerQuestionModel(
      id: id,
      eventId: map['eventId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      studentName: map['studentName'] as String? ?? 'Sinh viên ẩn danh',
      question: map['question'] as String? ?? '',
      upvotes: (map['upvotes'] as num?)?.toInt() ?? 0,
      timestamp: resolveDate(map['timestamp'], map['createdAt']),
      isAnswered: map['isAnswered'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'userId': userId,
      'studentName': studentName,
      'question': question,
      'upvotes': upvotes,
      'timestamp': timestamp.toIso8601String(),
      'isAnswered': isAnswered,
    };
  }
}
