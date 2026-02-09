import 'package:cloud_firestore/cloud_firestore.dart';

class CheckinModel {
  final String id;
  final String usuarioId;
  final String eventoId;
  final String? atividadeId;
  final DateTime timestamp;

  CheckinModel({
    required this.id,
    required this.usuarioId,
    required this.eventoId,
    this.atividadeId,
    required this.timestamp,
  });

  factory CheckinModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CheckinModel(
      id: doc.id,
      usuarioId: data['usuarioId'] ?? '',
      eventoId: data['eventoId'] ?? '',
      atividadeId: data['atividadeId'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'usuarioId': usuarioId,
      'eventoId': eventoId,
      'atividadeId': atividadeId,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
