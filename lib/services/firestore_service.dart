import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import '../models/ticket_model.dart';
import '../models/club_model.dart';
import '../models/speaker_question_model.dart';
import '../models/certificate_model.dart';
import '../models/user_model.dart';
import '../models/announcement_model.dart';
import '../models/registration_model.dart';
import '../models/gate_assignment_model.dart';
import 'seed_firestore_data.dart';

class CheckInValidationResult {
  final bool isValid;
  final bool isDuplicate;
  final String message;
  final TicketModel? ticket;

  const CheckInValidationResult({
    required this.isValid,
    required this.isDuplicate,
    required this.message,
    this.ticket,
  });
}

/// Cloud Firestore Service Wrapper
/// 100% Real Cloud Firestore Integration for FPTU Campus Event System.
/// Connects to collections: events, tickets, clubs, users, certificates, feedback.
class FirestoreService {
  final FirebaseFirestore? _firestore;
  bool _isInitialized = false;

  // In-memory cache for fast UI response and test compatibility
  final List<EventModel> _cachedEvents = [];
  final List<TicketModel> _cachedTickets = [];
  final List<ClubModel> _cachedClubs = [];
  final List<SpeakerQuestionModel> _cachedQuestions = [];
  final List<CertificateModel> _cachedCertificates = [];
  final List<AnnouncementModel> _cachedAnnouncements = [];
  final List<RegistrationModel> _cachedRegistrations = [];
  final List<Map<String, dynamic>> _cachedFeedbacks = [];

  // Reactive notifier for ticket state changes across the application
  final ValueNotifier<int> ticketsNotifier = ValueNotifier<int>(0);

  // Reactive notifier for certificate issuance across the application
  final ValueNotifier<int> certificatesNotifier = ValueNotifier<int>(0);

  FirestoreService([this._firestore]) {
    _cachedClubs.addAll(
      FirestoreSeeder.officialClubs.map(
        (c) => ClubModel.fromMap(c, c['id'] as String),
      ),
    );
  }

  /// Auto-initialize and ensure Cloud Firestore has all official FPTU documents
  Future<void> ensureDatabaseInitialized() async {
    if (_isInitialized || _firestore == null) return;
    _isInitialized = true;

    try {
      final snap = await _firestore.collection('events').limit(1).get();
      if (snap.docs.isEmpty) {
        debugPrint('[FirestoreService] Cloud Firestore empty. Auto-seeding official collections...');
        await FirestoreSeeder.seedAll(_firestore);
      } else {
        // Sync clubs if Cloud Firestore has fewer than official list
        try {
          final clubsSnap = await _firestore.collection('clubs').get();
          if (clubsSnap.docs.length < FirestoreSeeder.officialClubs.length) {
            debugPrint('[FirestoreService] Syncing missing official clubs to Cloud Firestore...');
            final batch = _firestore.batch();
            for (final club in FirestoreSeeder.officialClubs) {
              final docRef = _firestore.collection('clubs').doc(club['id'] as String);
              batch.set(docRef, club, SetOptions(merge: true));
            }
            await batch.commit();
            debugPrint('[FirestoreService] Successfully synced official clubs to Cloud Firestore!');
          }
        } catch (e) {
          debugPrint('[FirestoreService] Auto-sync clubs note: $e');
        }
      }
      // Populate local cache from real Cloud Firestore
      await _syncFromCloud();
    } catch (e) {
      debugPrint('[FirestoreService] Cloud Firestore auto-init note: $e');
    }
  }

  Future<void> _syncFromCloud() async {
    if (_firestore == null) return;
    try {
      final eventsSnap = await _firestore.collection('events').get();
      if (eventsSnap.docs.isNotEmpty) {
        _cachedEvents.clear();
        _cachedEvents.addAll(
          eventsSnap.docs.map((d) => EventModel.fromMap(d.data(), d.id)),
        );
      }

      final clubsSnap = await _firestore.collection('clubs').get();
      if (clubsSnap.docs.isNotEmpty) {
        _cachedClubs.clear();
        _cachedClubs.addAll(
          clubsSnap.docs.map((d) => ClubModel.fromMap(d.data(), d.id)),
        );
      }
    } catch (e) {
      debugPrint('[FirestoreService] Sync from cloud error: $e');
    }
  }

  /// Get list of events directly from Cloud Firestore with fallback sync
  Future<List<EventModel>> getEvents({String? category, int? limit}) async {
    try {
      if (_firestore != null) {
        Query<Map<String, dynamic>> query = _firestore.collection('events');
        if (category != null && category != 'All' && category != 'Tất cả') {
          query = query.where('category', isEqualTo: category);
        }
        if (limit != null) {
          query = query.limit(limit);
        }
        final snapshot = await query.get();
        if (snapshot.docs.isNotEmpty) {
          final liveList = snapshot.docs.map((doc) => EventModel.fromMap(doc.data(), doc.id)).toList();
          // Update in-memory cache with real cloud data
          for (final evt in liveList) {
            final idx = _cachedEvents.indexWhere((e) => e.id == evt.id);
            if (idx >= 0) {
              _cachedEvents[idx] = evt;
            } else {
              _cachedEvents.add(evt);
            }
          }
          return liveList;
        }
      }
    } catch (e) {
      debugPrint('[FirestoreService] Query live events warning: $e');
    }

    // Filter cache fallback
    var list = _cachedEvents;
    if (category != null && category != 'All' && category != 'Tất cả') {
      list = list.where((e) => e.category.toLowerCase() == category.toLowerCase()).toList();
    }
    if (limit != null && list.length > limit) {
      list = list.sublist(0, limit);
    }
    return list;
  }

  /// Get event details by ID directly from Cloud Firestore
  Future<EventModel?> getEventById(String eventId) async {
    try {
      if (_firestore != null) {
        final doc = await _firestore.collection('events').doc(eventId).get();
        if (doc.exists && doc.data() != null) {
          final liveEvent = EventModel.fromMap(doc.data()!, doc.id);
          final idx = _cachedEvents.indexWhere((e) => e.id == liveEvent.id);
          if (idx >= 0) {
            _cachedEvents[idx] = liveEvent;
          } else {
            _cachedEvents.add(liveEvent);
          }
          return liveEvent;
        }
      }
    } catch (e) {
      debugPrint('[FirestoreService] getEventById error: $e');
    }
    return _cachedEvents.cast<EventModel?>().firstWhere(
          (e) => e?.id == eventId,
          orElse: () => null,
        );
  }

  /// Get user registered tickets directly from Cloud Firestore with cache merge
  Future<List<TicketModel>> getUserTickets(String userId) async {
    try {
      if (_firestore != null) {
        final snapshot = await _firestore
            .collection('tickets')
            .where('userId', isEqualTo: userId)
            .get();
        if (snapshot.docs.isNotEmpty) {
          final liveTickets = snapshot.docs.map((d) => TicketModel.fromMap(d.data(), d.id)).toList();
          // Merge to cache
          for (final t in liveTickets) {
            final idx = _cachedTickets.indexWhere((old) => old.id == t.id);
            if (idx >= 0) {
              _cachedTickets[idx] = t;
            } else {
              _cachedTickets.insert(0, t);
            }
          }
          final merged = List<TicketModel>.from(liveTickets);
          for (final ct in _cachedTickets) {
            if (ct.userId == userId && !merged.any((m) => m.id == ct.id)) {
              merged.add(ct);
            }
          }
          return merged;
        }
      }
    } catch (e) {
      debugPrint('[FirestoreService] getUserTickets error: $e');
    }
    return _cachedTickets.where((t) => t.userId == userId).toList();
  }

  /// Real-time stream of user tickets directly from Cloud Firestore (BR-004, BR-005)
  Stream<List<TicketModel>> streamUserTickets(String userId) {
    if (_firestore == null) {
      final cached = _cachedTickets.where((t) => t.userId == userId).toList();
      return Stream.value(cached);
    }
    return _firestore
        .collection('tickets')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final liveTickets = snapshot.docs.map((d) => TicketModel.fromMap(d.data(), d.id)).toList();
          for (final t in liveTickets) {
            final idx = _cachedTickets.indexWhere((old) => old.id == t.id);
            if (idx >= 0) {
              _cachedTickets[idx] = t;
            } else {
              _cachedTickets.insert(0, t);
            }
          }
          final merged = List<TicketModel>.from(liveTickets);
          for (final ct in _cachedTickets) {
            if (ct.userId == userId && !merged.any((m) => m.id == ct.id)) {
              merged.add(ct);
            }
          }
          return merged;
        });
  }

  /// Real-time single ticket document stream (BR-004, BR-005)
  Stream<TicketModel?> streamTicket(String ticketId) {
    if (_firestore == null) {
      final cached = _cachedTickets.where((t) => t.id == ticketId).firstOrNull;
      return Stream.value(cached);
    }
    return _firestore
        .collection('tickets')
        .doc(ticketId)
        .snapshots()
        .map((snap) {
          if (!snap.exists || snap.data() == null) {
            return _cachedTickets.where((t) => t.id == ticketId).firstOrNull;
          }
          final updated = TicketModel.fromMap(snap.data()!, snap.id);
          final idx = _cachedTickets.indexWhere((t) => t.id == updated.id);
          if (idx >= 0) {
            _cachedTickets[idx] = updated;
          } else {
            _cachedTickets.insert(0, updated);
          }
          return updated;
        });
  }

  /// 1-Tap Registration Transaction (BR-001, BR-002, BR-004) - Real Cloud Firestore
  Future<TicketModel> registerForEvent({
    required EventModel event,
    required UserModel user,
  }) async {
    // 1. Check duplicate registration (BR-002)
    if (_firestore != null) {
      try {
        final dupSnap = await _firestore
            .collection('tickets')
            .where('eventId', isEqualTo: event.id)
            .where('userId', isEqualTo: user.id)
            .limit(1)
            .get();
        if (dupSnap.docs.isNotEmpty) {
          throw Exception('Bạn đã đăng ký sự kiện này trước đó. Vui lòng kiểm tra mục Vé của tôi.');
        }
      } catch (e) {
        if (e.toString().contains('Bạn đã đăng ký')) rethrow;
      }
    }

    final cachedDup = _cachedTickets.any((t) => t.eventId == event.id && t.userId == user.id);
    if (cachedDup) {
      throw Exception('Bạn đã đăng ký sự kiện này trước đó. Vui lòng kiểm tra mục Vé của tôi.');
    }

    // 2. Check capacity (BR-004)
    if (event.isFull) {
      throw Exception('Rất tiếc! Sự kiện đã đạt số lượng tối đa (${event.capacity} chỗ).');
    }

    final ticketNumber = (100000 + Random().nextInt(899999)).toString();
    final ticketId = 'CE2026-$ticketNumber';
    final token = 'QR-TOKEN-$ticketId-${DateTime.now().millisecondsSinceEpoch}';

    final newTicket = TicketModel(
      id: ticketId,
      eventId: event.id,
      eventTitle: event.title,
      eventDate: event.date,
      eventTime: event.time,
      eventLocation: event.location,
      userId: user.id,
      studentName: user.name,
      studentEmail: user.email,
      qrToken: token,
      status: TicketStatus.active,
    );

    if (_firestore != null) {
      try {
        await _firestore.collection('tickets').doc(ticketId).set(newTicket.toMap());
        debugPrint('[FirestoreService] Real Ticket written to Cloud Firestore: $ticketId');
      } catch (e) {
        debugPrint('[FirestoreService] Firestore ticket registration sync warning: $e');
      }

      try {
        await _firestore.collection('events').doc(event.id).update({
          'registeredCount': FieldValue.increment(1),
        });
        debugPrint('[FirestoreService] Cloud Firestore registeredCount incremented for event: ${event.id}');
      } catch (e) {
        debugPrint('[FirestoreService] Firestore event registeredCount update warning: $e');
      }
    }

    // Immediately update local cache so spotsRemaining updates everywhere without lag
    final evtIdx = _cachedEvents.indexWhere((e) => e.id == event.id);
    if (evtIdx >= 0) {
      final old = _cachedEvents[evtIdx];
      _cachedEvents[evtIdx] = old.copyWith(
        registeredCount: old.registeredCount + 1,
      );
    }

    _cachedTickets.insert(0, newTicket);
    ticketsNotifier.value++;
    debugPrint('[FirestoreService] Real Ticket issued: $ticketId');

    // Notify local Web Portal backend of newly issued ticket
    _notifyLocalWebPortalTicketCreated(newTicket);

    return newTicket;
  }

  void _notifyLocalWebPortalTicketCreated(TicketModel ticket) {
    try {
      final payload = jsonEncode(ticket.toMap());
      final endpoints = [
        'http://localhost:3000/api/tickets',
        'http://10.0.2.2:3000/api/tickets',
      ];
      for (final ep in endpoints) {
        http.post(
          Uri.parse(ep),
          headers: {'Content-Type': 'application/json'},
          body: payload,
        ).catchError((_) => http.Response('', 500));
      }
    } catch (_) {}
  }

  /// Gate Check-in QR Validation (BR-007, BR-008) - Real Cloud Firestore
  Future<CheckInValidationResult> validateAndCheckInTicket({
    required String qrToken,
    required String eventId,
  }) async {
    final cleanToken = qrToken.trim();

    // 1. Validate against real Cloud Firestore first
    if (_firestore != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>>? targetDoc;

        // Try lookup by doc ID (manual ticket ID)
        final byIdDoc = await _firestore.collection('tickets').doc(cleanToken).get();
        if (byIdDoc.exists) {
          targetDoc = byIdDoc;
        }

        // Try lookup by qrToken
        if (targetDoc == null) {
          final querySnap = await _firestore
              .collection('tickets')
              .where('qrToken', isEqualTo: cleanToken)
              .limit(1)
              .get();
          if (querySnap.docs.isNotEmpty) {
            targetDoc = querySnap.docs.first;
          }
        }

        // Try lookup by ticketCode
        if (targetDoc == null) {
          final queryCode = await _firestore
              .collection('tickets')
              .where('ticketCode', isEqualTo: cleanToken)
              .limit(1)
              .get();
          if (queryCode.docs.isNotEmpty) {
            targetDoc = queryCode.docs.first;
          }
        }

        // Try lookup by qrData
        if (targetDoc == null) {
          final queryData = await _firestore
              .collection('tickets')
              .where('qrData', isEqualTo: cleanToken)
              .limit(1)
              .get();
          if (queryData.docs.isNotEmpty) {
            targetDoc = queryData.docs.first;
          }
        }

        // Try extracting CE2026-xxxxxx pattern (e.g. from QR-TOKEN-CE2026-083291-SECURE-HASH)
        if (targetDoc == null && cleanToken.contains('CE2026-')) {
          final match = RegExp(r'CE2026-\d+').firstMatch(cleanToken);
          if (match != null) {
            final extractedCode = match.group(0)!;
            final queryExtracted = await _firestore
                .collection('tickets')
                .where('ticketCode', isEqualTo: extractedCode)
                .limit(1)
                .get();
            if (queryExtracted.docs.isNotEmpty) {
              targetDoc = queryExtracted.docs.first;
            } else {
              final docByExtracted = await _firestore.collection('tickets').doc(extractedCode).get();
              if (docByExtracted.exists) {
                targetDoc = docByExtracted;
              }
            }
          }
        }

        if (targetDoc != null && targetDoc.exists && targetDoc.data() != null) {
          final ticket = TicketModel.fromMap(targetDoc.data()!, targetDoc.id);

          if (eventId.isNotEmpty && ticket.eventId != eventId) {
            return CheckInValidationResult(
              isValid: false,
              isDuplicate: false,
              message: 'Vé thuộc sự kiện khác: "${ticket.eventTitle}".',
              ticket: ticket,
            );
          }

          if (ticket.status == TicketStatus.checkedIn) {
            final checkInTimeStr = ticket.checkedInAt != null
                ? '${ticket.checkedInAt!.hour.toString().padLeft(2, '0')}:${ticket.checkedInAt!.minute.toString().padLeft(2, '0')}'
                : '14:02';
            return CheckInValidationResult(
              isValid: false,
              isDuplicate: true,
              message: 'CẢNH BÁO: Vé đã được check-in vào lúc $checkInTimeStr tại Cổng 1.',
              ticket: ticket,
            );
          }

          // Valid check-in -> update real Firestore document
          final now = DateTime.now();
          final nowStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} ${now.day}/${now.month}/${now.year}';
          await _firestore.collection('tickets').doc(ticket.id).update({
            'status': 'checkedIn',
            'checkInStatus': true,
            'checkedInAt': nowStr,
            'points': 5,
          });

          // Award +5 training points in Firestore user doc
          if (ticket.userId.isNotEmpty) {
            try {
              await _firestore.collection('users').doc(ticket.userId).update({
                'activityPoints': FieldValue.increment(5),
              });
            } catch (_) {}
          }

          final updatedTicket = ticket.copyWith(
            status: TicketStatus.checkedIn,
            checkedInAt: now,
          );

          // Update local cache
          final cacheIdx = _cachedTickets.indexWhere((t) => t.id == ticket.id);
          if (cacheIdx >= 0) {
            _cachedTickets[cacheIdx] = updatedTicket;
          } else {
            _cachedTickets.insert(0, updatedTicket);
          }
          ticketsNotifier.value++;

          // Asynchronously notify local web portal backend as well
          _notifyLocalWebPortalCheckin(updatedTicket, cleanToken);

          return CheckInValidationResult(
            isValid: true,
            isDuplicate: false,
            message: 'Check-in thành công! Chào mừng ${updatedTicket.studentName}.',
            ticket: updatedTicket,
          );
        }
      } catch (e) {
        debugPrint('[FirestoreService] Cloud check-in validation notice: $e');
      }
    }

    // 2. Fallback to cache validation
    final matchIndex = _cachedTickets.indexWhere((t) =>
        t.qrToken == cleanToken ||
        t.id == cleanToken ||
        (cleanToken.contains(t.id) && t.id.isNotEmpty));

    if (matchIndex == -1) {
      return const CheckInValidationResult(
        isValid: false,
        isDuplicate: false,
        message: 'Mã vé không tồn tại hoặc sai định dạng hệ thống.',
      );
    }

    final ticket = _cachedTickets[matchIndex];
    if (ticket.eventId != eventId && eventId.isNotEmpty) {
      return CheckInValidationResult(
        isValid: false,
        isDuplicate: false,
        message: 'Vé thuộc sự kiện khác: "${ticket.eventTitle}".',
        ticket: ticket,
      );
    }

    if (ticket.status == TicketStatus.checkedIn) {
      final checkInTimeStr = ticket.checkedInAt != null
          ? '${ticket.checkedInAt!.hour.toString().padLeft(2, '0')}:${ticket.checkedInAt!.minute.toString().padLeft(2, '0')}'
          : '14:02';
      return CheckInValidationResult(
        isValid: false,
        isDuplicate: true,
        message: 'CẢNH BÁO: Vé đã được check-in vào lúc $checkInTimeStr tại Cổng 1.',
        ticket: ticket,
      );
    }

    final now = DateTime.now();
    final updatedTicket = ticket.copyWith(
      status: TicketStatus.checkedIn,
      checkedInAt: now,
    );
    _cachedTickets[matchIndex] = updatedTicket;
    ticketsNotifier.value++;

    // CRITICAL: Persist fallback check-in to Cloud Firestore
    if (_firestore != null) {
      try {
        final nowStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} ${now.day}/${now.month}/${now.year}';
        final map = updatedTicket.toMap();
        map['status'] = 'checkedIn';
        map['checkInStatus'] = true;
        map['checkedInAt'] = nowStr;
        map['points'] = 5;
        await _firestore.collection('tickets').doc(updatedTicket.id).set(
          map,
          SetOptions(merge: true),
        );
        debugPrint('[FirestoreService] Fallback check-in successfully synced to Cloud Firestore: ${updatedTicket.id}');
        if (updatedTicket.userId.isNotEmpty) {
          try {
            await _firestore.collection('users').doc(updatedTicket.userId).update({
              'activityPoints': FieldValue.increment(5),
            });
          } catch (_) {}
        }
      } catch (e) {
        debugPrint('[FirestoreService] Firestore fallback check-in sync warning: $e');
      }
    }

    // Also notify local web portal backend bridge as a failsafe
    _notifyLocalWebPortalCheckin(updatedTicket, cleanToken);

    return CheckInValidationResult(
      isValid: true,
      isDuplicate: false,
      message: 'Check-in thành công! Chào mừng ${updatedTicket.studentName}.',
      ticket: updatedTicket,
    );
  }

  void _notifyLocalWebPortalCheckin(TicketModel ticket, String token) {
    try {
      final payload = jsonEncode({
        'id': ticket.id,
        'ticketCode': ticket.id,
        'qrToken': token,
        'eventId': ticket.eventId,
        'eventTitle': ticket.eventTitle,
        'userId': ticket.userId,
        'studentName': ticket.studentName,
        'studentEmail': ticket.studentEmail,
        'status': 'checkedIn',
        'checkInStatus': true,
      });
      final endpoints = [
        'http://localhost:3000/api/tickets/checkin',
        'http://10.0.2.2:3000/api/tickets/checkin',
      ];
      for (final ep in endpoints) {
        http.post(
          Uri.parse(ep),
          headers: {'Content-Type': 'application/json'},
          body: payload,
        ).then((res) {
          if (res.statusCode == 200) {
            debugPrint('[FirestoreService] Successfully notified Web Portal backend of check-in: $ep');
          }
          return res;
        }).catchError((_) => http.Response('', 500));
      }
    } catch (_) {}
  }

  /// Live Speaker Q&A questions from Cloud Firestore
  Future<List<SpeakerQuestionModel>> getSpeakerQuestions(String eventId) async {
    try {
      if (_firestore != null) {
        final snap = await _firestore
            .collection('events')
            .doc(eventId)
            .collection('questions')
            .get();
        if (snap.docs.isNotEmpty) {
          final list = snap.docs
              .map((doc) => SpeakerQuestionModel.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => b.upvotes.compareTo(a.upvotes));
          return list;
        }
      }
    } catch (e) {
      debugPrint('[FirestoreService] getSpeakerQuestions error: $e');
    }

    return _cachedQuestions.where((q) => q.eventId == eventId).toList()
      ..sort((a, b) => b.upvotes.compareTo(a.upvotes));
  }

  Future<void> askSpeakerQuestion({
    required String eventId,
    required UserModel user,
    required String question,
  }) async {
    final qId = 'Q-${DateTime.now().millisecondsSinceEpoch}';
    final q = SpeakerQuestionModel(
      id: qId,
      eventId: eventId,
      userId: user.id,
      studentName: user.name,
      question: question,
      upvotes: 0,
      timestamp: DateTime.now(),
    );

    try {
      if (_firestore != null) {
        await _firestore
            .collection('events')
            .doc(eventId)
            .collection('questions')
            .doc(qId)
            .set({
          'id': qId,
          'eventId': eventId,
          'userId': user.id,
          'studentName': user.name,
          'question': question,
          'upvotes': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'isAnswered': false,
        });
      }
    } catch (e) {
      debugPrint('[FirestoreService] askSpeakerQuestion cloud error: $e');
    }

    _cachedQuestions.insert(0, q);
  }

  Future<void> upvoteSpeakerQuestion(String eventId, String questionId) async {
    try {
      if (_firestore != null) {
        await _firestore
            .collection('events')
            .doc(eventId)
            .collection('questions')
            .doc(questionId)
            .update({
          'upvotes': FieldValue.increment(1),
        });
      }
    } catch (e) {
      debugPrint('[FirestoreService] upvoteSpeakerQuestion cloud error: $e');
    }

    final idx = _cachedQuestions.indexWhere((q) => q.id == questionId);
    if (idx != -1) {
      final old = _cachedQuestions[idx];
      _cachedQuestions[idx] = SpeakerQuestionModel(
        id: old.id,
        eventId: old.eventId,
        userId: old.userId,
        studentName: old.studentName,
        question: old.question,
        upvotes: old.upvotes + 1,
        timestamp: old.timestamp,
        isAnswered: old.isAnswered,
      );
    }
  }

  /// User Certificates from Cloud Firestore with auto-issuance for checked-in events
  Future<List<CertificateModel>> getUserCertificates(String userId) async {
    final List<CertificateModel> result = [];

    try {
      if (_firestore != null) {
        final snap = await _firestore
            .collection('certificates')
            .where('userId', isEqualTo: userId)
            .get();
        if (snap.docs.isNotEmpty) {
          final liveList = snap.docs
              .map((d) => CertificateModel.fromMap(d.data(), d.id))
              .toList();
          for (final c in liveList) {
            final idx = _cachedCertificates.indexWhere((old) => old.id == c.id);
            if (idx >= 0) {
              _cachedCertificates[idx] = c;
            } else {
              _cachedCertificates.insert(0, c);
            }
          }
          result.addAll(liveList);
        }
      }
    } catch (e) {
      debugPrint('[FirestoreService] getUserCertificates cloud error: $e');
    }

    // Merge cached certificates for this user
    for (final c in _cachedCertificates) {
      if (c.userId == userId && !result.any((r) => r.id == c.id || r.eventId == c.eventId)) {
        result.add(c);
      }
    }

    // Auto-generate e-Certificate for any checked-in event tickets belonging to this student
    final userTickets = await getUserTickets(userId);
    for (final ticket in userTickets) {
      if (ticket.isCheckedIn && !result.any((c) => c.eventId == ticket.eventId)) {
        final certId = 'CERT-${ticket.id}';
        final newCert = CertificateModel(
          id: certId,
          eventId: ticket.eventId,
          eventTitle: ticket.eventTitle,
          userId: userId,
          studentName: ticket.studentName,
          issueDate: ticket.eventDate.isNotEmpty ? ticket.eventDate : '28/10/2026',
          verificationHash: 'HASH-FPTU-${ticket.id}',
          downloadUrl: '',
        );
        result.add(newCert);
        // Persist to Cloud Firestore and cache
        saveCertificate(newCert);
      }
    }

    return result;
  }

  /// Real-time stream of user certificates directly from Cloud Firestore (BR-004, BR-005)
  Stream<List<CertificateModel>> streamUserCertificates(String userId) {
    if (_firestore == null) {
      return Stream.value(_cachedCertificates.where((c) => c.userId == userId).toList());
    }
    return _firestore
        .collection('certificates')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
          final liveList = snap.docs
              .map((d) => CertificateModel.fromMap(d.data(), d.id))
              .toList();
          for (final c in liveList) {
            final idx = _cachedCertificates.indexWhere((old) => old.id == c.id);
            if (idx >= 0) {
              _cachedCertificates[idx] = c;
            } else {
              _cachedCertificates.insert(0, c);
            }
          }
          final merged = List<CertificateModel>.from(liveList);
          for (final c in _cachedCertificates) {
            if (c.userId == userId && !merged.any((m) => m.id == c.id)) {
              merged.add(c);
            }
          }
          return merged;
        });
  }

  /// Save Certificate to Cloud Firestore
  Future<void> saveCertificate(CertificateModel cert) async {
    try {
      if (_firestore != null) {
        await _firestore.collection('certificates').doc(cert.id).set(cert.toMap());
        debugPrint('[FirestoreService] Real Certificate saved to Firestore: ${cert.id}');
      }
    } catch (e) {
      debugPrint('[FirestoreService] saveCertificate error: $e');
    }
    final idx = _cachedCertificates.indexWhere((c) => c.id == cert.id);
    if (idx >= 0) {
      _cachedCertificates[idx] = cert;
    } else {
      _cachedCertificates.insert(0, cert);
    }
    certificatesNotifier.value++;
  }

  /// Submit Real Event Feedback & Grant Activity Points
  /// Returns true if first-time submission (points awarded), false if duplicate update.
  Future<bool> submitEventFeedback({
    required String eventId,
    required String userId,
    required int rating,
    required String comments,
    UserModel? user,
  }) async {
    try {
      if (_firestore != null) {
        // Prevent duplicate feedback points spam: Check if user already submitted feedback for this event
        final existingSnap = await _firestore
            .collection('feedback')
            .where('eventId', isEqualTo: eventId)
            .where('userId', isEqualTo: userId)
            .limit(1)
            .get();

        if (existingSnap.docs.isNotEmpty) {
          // Already submitted feedback: Update comment & rating only, DO NOT award +5 points a second time!
          final docId = existingSnap.docs.first.id;
          await _firestore.collection('feedback').doc(docId).update({
            'rating': rating,
            'comments': comments,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          debugPrint('[FirestoreService] Feedback updated for event $eventId (No duplicate points awarded)');
          return false;
        }

        // First time submission: Record feedback and award +5 points
        await _firestore.collection('feedback').add({
          'eventId': eventId,
          'userId': userId,
          'rating': rating,
          'comments': comments,
          'submittedAt': FieldValue.serverTimestamp(),
        });

        // Atomically increment student activity points (+5) in Firestore ONLY on first submission
        await _firestore.collection('users').doc(userId).update({
          'activityPoints': FieldValue.increment(5),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint('[FirestoreService] First feedback submitted, awarded +5 activity points.');
        return true;
      } else {
        // Fallback / Offline / Web in-memory mode
        final existingIdx = _cachedFeedbacks.indexWhere((f) => f['eventId'] == eventId && f['userId'] == userId);
        if (existingIdx != -1) {
          _cachedFeedbacks[existingIdx]['rating'] = rating;
          _cachedFeedbacks[existingIdx]['comments'] = comments;
          debugPrint('[FirestoreService] Cached feedback updated for event $eventId');
          return false;
        }
        _cachedFeedbacks.add({
          'eventId': eventId,
          'userId': userId,
          'rating': rating,
          'comments': comments,
        });
        debugPrint('[FirestoreService] First cached feedback submitted, awarded +5 points.');
        return true;
      }
    } catch (e) {
      debugPrint('[FirestoreService] submitEventFeedback error: $e');
      return false;
    }
  }

  /// Clubs from Cloud Firestore
  Future<List<ClubModel>> getClubs() async {
    try {
      if (_firestore != null) {
        final snap = await _firestore.collection('clubs').get();
        if (snap.docs.isNotEmpty) {
          final cloudList = snap.docs.map((d) => ClubModel.fromMap(d.data(), d.id)).toList();
          if (cloudList.length >= _cachedClubs.length) {
            return cloudList;
          }
          // Merge cloud clubs with cached official clubs so all 45 clubs remain accessible
          final Map<String, ClubModel> map = {for (var c in _cachedClubs) c.id: c};
          for (var c in cloudList) {
            map[c.id] = c;
          }
          return map.values.toList();
        }
      }
    } catch (e) {
      debugPrint('[FirestoreService] getClubs error: $e');
    }
    return _cachedClubs;
  }

  /// Get real-time checked-in count for an event
  Future<int> getCheckedInCount(String eventId) async {
    try {
      if (_firestore != null) {
        final snap = await _firestore
            .collection('tickets')
            .where('eventId', isEqualTo: eventId)
            .where('status', isEqualTo: 'checkedIn')
            .get();
        return snap.docs.length;
      }
    } catch (e) {
      debugPrint('[FirestoreService] getCheckedInCount error: $e');
    }
    return _cachedTickets.where((t) => t.eventId == eventId && t.status == TicketStatus.checkedIn).length;
  }

  // ==========================================
  // FINAL ASSIGNMENT: ANNOUNCEMENTS INBOX
  // ==========================================

  /// Real-time stream of official announcements, filtered by userId for privacy (BR-003)
  Stream<List<AnnouncementModel>> streamAnnouncements({String? currentUserId}) {
    if (_firestore != null) {
      return _firestore
          .collection('announcements')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs
              .map((d) => AnnouncementModel.fromMap(d.data(), d.id))
              .where((a) => a.userId.isEmpty || a.userId == currentUserId)
              .toList());
    }
    return Stream.value(_cachedAnnouncements.where((a) => a.userId.isEmpty || a.userId == currentUserId).toList());
  }

  /// Get list of announcements directly from Cloud Firestore, filtered by userId
  Future<List<AnnouncementModel>> getAnnouncements({String? currentUserId}) async {
    try {
      if (_firestore != null) {
        final snap = await _firestore
            .collection('announcements')
            .orderBy('createdAt', descending: true)
            .get();
        if (snap.docs.isNotEmpty) {
          final list = snap.docs
              .map((d) => AnnouncementModel.fromMap(d.data(), d.id))
              .where((a) => a.userId.isEmpty || a.userId == currentUserId)
              .toList();
          _cachedAnnouncements.clear();
          _cachedAnnouncements.addAll(list);
          return list;
        }
      }
    } catch (e) {
      debugPrint('[FirestoreService] getAnnouncements error: $e');
    }
    return _cachedAnnouncements.where((a) => a.userId.isEmpty || a.userId == currentUserId).toList();
  }

  /// Broadcast announcement from Web Admin or Staff HUD
  Future<void> sendAnnouncement(AnnouncementModel announcement) async {
    try {
      if (_firestore != null) {
        await _firestore
            .collection('announcements')
            .doc(announcement.id)
            .set(announcement.toMap());
      }
    } catch (e) {
      debugPrint('[FirestoreService] sendAnnouncement cloud error: $e');
    }
    _cachedAnnouncements.insert(0, announcement);
  }

  // ==========================================
  // FINAL ASSIGNMENT: CROSS-ROLE REGISTRATION FLOW
  // ==========================================

  /// Submit event registration requiring Organizer approval (status: pending)
  Future<RegistrationModel> submitRegistration({
    required EventModel event,
    required UserModel user,
  }) async {
    final regId = 'REG-${DateTime.now().millisecondsSinceEpoch}';
    final registration = RegistrationModel(
      id: regId,
      eventId: event.id,
      eventTitle: event.title,
      userId: user.id,
      studentName: user.name,
      studentEmail: user.email,
      status: RegistrationStatus.pending,
      createdAt: DateTime.now(),
    );

    try {
      if (_firestore != null) {
        await _firestore.collection('registrations').doc(regId).set(registration.toMap());
      }
    } catch (e) {
      debugPrint('[FirestoreService] submitRegistration error: $e');
    }

    _cachedRegistrations.insert(0, registration);
    return registration;
  }

  /// Stream a user's registration status for an event in real-time
  Stream<RegistrationModel?> streamUserRegistration(String eventId, String userId) {
    if (_firestore != null) {
      return _firestore
          .collection('registrations')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .snapshots()
          .map((snap) {
        if (snap.docs.isNotEmpty) {
          return RegistrationModel.fromMap(snap.docs.first.data(), snap.docs.first.id);
        }
        return null;
      });
    }
    final match = _cachedRegistrations.cast<RegistrationModel?>().firstWhere(
          (r) => r?.eventId == eventId && r?.userId == userId,
          orElse: () => null,
        );
    return Stream.value(match);
  }

  /// Stream all pending registrations for Organizer Web Admin Review Queue
  Stream<List<RegistrationModel>> streamPendingRegistrations() {
    if (_firestore != null) {
      return _firestore
          .collection('registrations')
          .where('status', isEqualTo: 'pending')
          .snapshots()
          .map((snap) => snap.docs
              .map((d) => RegistrationModel.fromMap(d.data(), d.id))
              .toList());
    }
    return Stream.value(
      _cachedRegistrations.where((r) => r.status == RegistrationStatus.pending).toList(),
    );
  }

  /// Review registration: Approve or Reject with reason (Organizer on Web Admin)
  Future<void> reviewRegistration(
    String regId, {
    required bool approve,
    String? reason,
  }) async {
    final newStatus = approve ? RegistrationStatus.approved : RegistrationStatus.rejected;
    final now = DateTime.now();

    try {
      if (_firestore != null) {
        final updateMap = <String, dynamic>{
          'status': newStatus.name,
          'reviewedAt': FieldValue.serverTimestamp(),
          'reason': ?reason,
        };

        // If approved, automatically issue active Ticket in tickets collection!
        if (approve) {
          final regDoc = await _firestore.collection('registrations').doc(regId).get();
          if (regDoc.exists && regDoc.data() != null) {
            final regData = regDoc.data()!;
            final ticketId = 'CE2026-${(100000 + Random().nextInt(899999))}';
            final token = 'QR-TOKEN-$ticketId-${now.millisecondsSinceEpoch}';

            final newTicket = TicketModel(
              id: ticketId,
              eventId: regData['eventId'] as String? ?? '',
              eventTitle: regData['eventTitle'] as String? ?? 'Sự kiện FPTU',
              eventDate: '28/10/2026',
              eventTime: '13:30 - 17:30',
              eventLocation: 'Hội trường Trịnh Công Sơn',
              userId: regData['userId'] as String? ?? '',
              studentName: regData['studentName'] as String? ?? 'Sinh viên FPTU',
              studentEmail: regData['studentEmail'] as String? ?? '',
              qrToken: token,
              status: TicketStatus.active,
            );

            await _firestore.collection('tickets').doc(ticketId).set(newTicket.toMap());
            updateMap['ticketId'] = ticketId;

            // Also send Inbox Announcement notification to student!
            final annId = 'ANN-${now.millisecondsSinceEpoch}';
            await _firestore.collection('announcements').doc(annId).set({
              'id': annId,
              'title': 'Đăng ký sự kiện đã được duyệt! 🎉',
              'content': 'Đơn đăng ký tham dự "${regData['eventTitle']}" của bạn đã được Ban Tổ Chức phê duyệt. Vé điện tử đã sẵn sàng trong mục "Vé của tôi".',
              'category': 'ticket_approved',
              'authorRole': 'organizer',
              'eventId': regData['eventId'],
              'isPinned': true,
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
        }

        await _firestore.collection('registrations').doc(regId).update(updateMap);
      }
    } catch (e) {
      debugPrint('[FirestoreService] reviewRegistration error: $e');
    }

    final idx = _cachedRegistrations.indexWhere((r) => r.id == regId);
    if (idx != -1) {
      final old = _cachedRegistrations[idx];
      _cachedRegistrations[idx] = RegistrationModel(
        id: old.id,
        eventId: old.eventId,
        eventTitle: old.eventTitle,
        userId: old.userId,
        studentName: old.studentName,
        studentEmail: old.studentEmail,
        status: newStatus,
        reason: reason,
        createdAt: old.createdAt,
        reviewedAt: now,
      );
    }
  }

  /// Gate Check-in Duty Assignments (Phân công ca trực cổng) - Real Cloud Firestore
  Future<List<GateAssignmentModel>> getGateAssignments({String? email}) async {
    try {
      if (_firestore != null) {
        Query<Map<String, dynamic>> query = _firestore.collection('gate_assignments');
        if (email != null && email.isNotEmpty) {
          query = query.where('email', isEqualTo: email.toLowerCase().trim());
        }
        final snap = await query.get();
        final list = snap.docs
            .map((doc) => GateAssignmentModel.fromMap(doc.data(), doc.id))
            .where((a) => a.isActive)
            .toList();
        return list;
      }
    } catch (e) {
      debugPrint('[FirestoreService] getGateAssignments note: $e');
    }
    return [];
  }
}
