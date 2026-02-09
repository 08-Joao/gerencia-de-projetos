import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/checkin_model.dart';
import '../services/firestore_service.dart';

class CheckinProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;
  String? _error;
  bool _hasCheckedIn = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasCheckedIn => _hasCheckedIn;

  Future<void> checkEventCheckinStatus(String usuarioId, String eventoId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _hasCheckedIn =
          await _firestoreService.hasCheckinInEvent(usuarioId, eventoId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> performCheckin({
    required String usuarioId,
    required String eventoId,
    required String? atividadeId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final checkin = CheckinModel(
        id: const Uuid().v4(),
        usuarioId: usuarioId,
        eventoId: eventoId,
        atividadeId: atividadeId,
        timestamp: DateTime.now(),
      );

      await _firestoreService.createCheckin(checkin);
      _hasCheckedIn = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
