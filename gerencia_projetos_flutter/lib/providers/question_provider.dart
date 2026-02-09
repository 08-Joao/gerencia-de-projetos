import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/question_model.dart';
import '../services/firestore_service.dart';

class QuestionProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<PerguntaModel> _perguntas = [];
  List<PerguntaModel> _minhasPerguntas = [];
  List<PerguntaModel> _perguntasPendentes = [];
  bool _isLoading = false;
  String? _error;

  List<PerguntaModel> get perguntas => _perguntas;
  List<PerguntaModel> get minhasPerguntas => _minhasPerguntas;
  List<PerguntaModel> get perguntasPendentes => _perguntasPendentes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final List<String> _palavrasInapropriadas = [
    'spam',
    'xingamento',
    'ofensa',
  ];

  Future<void> loadPerguntasByAtividade(String atividadeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _perguntas =
          await _firestoreService.getPerguntasByAtividade(atividadeId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMinhasPerguntas(String usuarioId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _minhasPerguntas =
          await _firestoreService.getMinhasPerguntasByUsuario(usuarioId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPerguntasPendentes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _perguntasPendentes = await _firestoreService.getPerguntasPendentes();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _containsInappropriateContent(String texto) {
    final textoLower = texto.toLowerCase();
    return _palavrasInapropriadas
        .any((palavra) => textoLower.contains(palavra));
  }

  Future<void> submitQuestion({
    required String atividadeId,
    required String autorId,
    required String autorNome,
    required String texto,
  }) async {
    if (_containsInappropriateContent(texto)) {
      _error = 'A pergunta contém conteúdo inapropriado';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final pergunta = PerguntaModel(
        id: const Uuid().v4(),
        atividadeId: atividadeId,
        autorId: autorId,
        autorNome: autorNome,
        texto: texto,
        status: StatusPergunta.pendente,
        criadaEm: DateTime.now(),
        respondida: false,
      );

      await _firestoreService.createPergunta(pergunta);
      await loadMinhasPerguntas(autorId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> approvePergunta(String perguntaId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.approvePergunta(perguntaId);
      await loadPerguntasPendentes();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rejectPergunta(String perguntaId, String motivo) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.rejectPergunta(perguntaId, motivo);
      await loadPerguntasPendentes();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
