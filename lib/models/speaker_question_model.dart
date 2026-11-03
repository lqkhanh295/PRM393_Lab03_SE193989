class SpeakerQuestionModel {
  final String id;
  final String eventId;
  final String userId;
  final String studentName;
  final String question;
  final int upvotes;
  final DateTime timestamp;

  const SpeakerQuestionModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.studentName,
    required this.question,
    required this.upvotes,
    required this.timestamp,
  });

  factory SpeakerQuestionModel.fromMap(Map<String, dynamic> map, String id) {
    return SpeakerQuestionModel(
      id: id,
      eventId: map['eventId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      studentName: map['studentName'] as String? ?? 'Sinh viên ẩn danh',
      question: map['question'] as String? ?? '',
      upvotes: (map['upvotes'] as num?)?.toInt() ?? 0,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
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
    };
  }
}
