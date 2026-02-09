import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/activity_model.dart';
import '../services/firestore_service.dart';

class EventProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<EventoModel> _eventos = [];
  List<AtividadeModel> _atividades = [];
  List<AtividadeModel> _atividadesFiltradas = [];
  bool _isLoading = false;
  String? _error;

  EventoModel? _eventoAtual;

  List<AtividadeModel> get atividades => _atividadesFiltradas.isEmpty ? _atividades : _atividadesFiltradas;
  List<EventoModel> get eventos => _eventos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  EventoModel? get eventoAtual => _eventoAtual;

  Future<void> loadEventos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _eventos = await _firestoreService.getEventos();
      if (_eventos.isNotEmpty) {
        _eventoAtual = _eventos.first;
        await loadAtividades(_eventoAtual!.id);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAtividades(String eventoId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _atividades = await _firestoreService.getAtividadesByEvento(eventoId);
      _atividadesFiltradas = [];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterByTipo(String tipo) {
    if (tipo.isEmpty) {
      _atividadesFiltradas = [];
    } else {
      _atividadesFiltradas = _atividades
          .where((a) => a.tipo.toString().split('.').last == tipo)
          .toList();
    }
    notifyListeners();
  }

  void filterByTag(String tag) {
    if (tag.isEmpty) {
      _atividadesFiltradas = [];
    } else {
      _atividadesFiltradas =
          _atividades.where((a) => a.tags.contains(tag)).toList();
    }
    notifyListeners();
  }

  void filterByPalestrante(String palestranteNome) {
    if (palestranteNome.isEmpty) {
      _atividadesFiltradas = [];
    } else {
      _atividadesFiltradas = _atividades
          .where((a) => a.palestranteNome
              .toLowerCase()
              .contains(palestranteNome.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void clearFilters() {
    _atividadesFiltradas = [];
    notifyListeners();
  }

  List<String> getAllTags() {
    final tags = <String>{};
    for (var atividade in _atividades) {
      tags.addAll(atividade.tags);
    }
    return tags.toList();
  }

  List<String> getAllPalestrantes() {
    final palestrantes = <String>{};
    for (var atividade in _atividades) {
      palestrantes.add(atividade.palestranteNome);
    }
    return palestrantes.toList();
  }

  Future<void> createEvento(EventoModel evento) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.createEvento(evento);
      await loadEventos();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
