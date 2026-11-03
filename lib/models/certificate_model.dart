class CertificateModel {
  final String id;
  final String eventId;
  final String eventTitle;
  final String userId;
  final String studentName;
  final String issueDate;
  final String verificationHash;
  final String downloadUrl;

  const CertificateModel({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.userId,
    required this.studentName,
    required this.issueDate,
    required this.verificationHash,
    required this.downloadUrl,
  });

  factory CertificateModel.fromMap(Map<String, dynamic> map, String id) {
    return CertificateModel(
      id: id,
      eventId: map['eventId'] as String? ?? '',
      eventTitle: map['eventTitle'] as String? ?? 'Sự kiện FPTU',
      userId: map['userId'] as String? ?? '',
      studentName: map['studentName'] as String? ?? 'Sinh viên FPTU',
      issueDate: map['issueDate'] as String? ?? '28/10/2026',
      verificationHash: map['verificationHash'] as String? ?? 'HASH-FPTU-CERT-$id',
      downloadUrl: map['downloadUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'eventTitle': eventTitle,
      'userId': userId,
      'studentName': studentName,
      'issueDate': issueDate,
      'verificationHash': verificationHash,
      'downloadUrl': downloadUrl,
    };
  }
}
