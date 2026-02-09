import 'package:flutter/material.dart';
import '../models/agenda_model.dart';
import '../models/activity_model.dart';
import '../services/firestore_service.dart';

class AgendaProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ItemAgendaModel> _agenda = [];
  bool _isLoading = false;
  String? _error;

  List<ItemAgendaModel> get agenda => _agenda;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAgenda(String usuarioId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _agenda = await _firestoreService.getAgenda(usuarioId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToAgenda(
    String usuarioId,
    String atividadeId,
    int lembreteMinutos,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final item = ItemAgendaModel(
        atividadeId: atividadeId,
        adicionadaEm: DateTime.now(),
        lembreteMinutos: lembreteMinutos,
      );
      await _firestoreService.addToAgenda(usuarioId, item);
      await loadAgenda(usuarioId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFromAgenda(String usuarioId, String atividadeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.removeFromAgenda(usuarioId, atividadeId);
      await loadAgenda(usuarioId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> isInAgenda(String usuarioId, String atividadeId) async {
    try {
      return await _firestoreService.isInAgenda(usuarioId, atividadeId);
    } catch (e) {
      return false;
    }
  }

  bool hasConflict(
    AtividadeModel novaAtividade,
    List<AtividadeModel> todasAtividades,
  ) {
    for (var item in _agenda) {
      final atividades = todasAtividades.where((a) => a.id == item.atividadeId).toList();
      if (atividades.isNotEmpty) {
        final atividade = atividades.first;
        if (novaAtividade.horaInicio.isBefore(atividade.horaFim) &&
            novaAtividade.horaFim.isAfter(atividade.horaInicio)) {
          return true;
        }
      }
    }
    return false;
  }
}
