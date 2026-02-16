import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/question_model.dart';
import '../models/activity_model.dart';
import '../models/aviso_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class AdminProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  List<UsuarioModel> _palestrantesPendentes = [];
  List<PerguntaModel> _perguntasPendentes = [];
  List<AtividadeModel> _atividadesPendentes = [];
  List<UsuarioModel> _allUsers = [];
  int _totalParticipantes = 0;
  int _totalCheckins = 0;
  int _totalPalestrantes = 0;
  int _totalPalestrantesAprovados = 0;
  bool _isLoading = false;
  String? _error;

  List<UsuarioModel> get palestrantesPendentes => _palestrantesPendentes;
  List<PerguntaModel> get perguntasPendentes => _perguntasPendentes;
  List<AtividadeModel> get atividadesPendentes => _atividadesPendentes;
  List<UsuarioModel> get allUsers => _allUsers;
  int get totalParticipantes => _totalParticipantes;
  int get totalCheckins => _totalCheckins;
  int get totalPalestrantes => _totalPalestrantes;
  int get totalPalestrantesAprovados => _totalPalestrantesAprovados;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadPalestrantesPendentes(),
        _loadPerguntasPendentes(),
        _loadAtividadesPendentes(),
        _loadTotalParticipantes(),
        _loadTotalCheckins(),
        _loadTotalPalestrantes(),
        _loadTotalPalestrantesAprovados(),
      ]);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadPalestrantesPendentes() async {
    try {
      _palestrantesPendentes =
          await _firestoreService.getPalestrantesPendentes();
    } catch (e) {
      print('Erro ao carregar palestrantes pendentes: $e');
    }
  }

  Future<void> _loadPerguntasPendentes() async {
    try {
      _perguntasPendentes = await _firestoreService.getPerguntasPendentes();
    } catch (e) {
      print('Erro ao carregar perguntas pendentes: $e');
    }
  }

  Future<void> _loadAtividadesPendentes() async {
    try {
      _atividadesPendentes = await _firestoreService.getAtividadesPendentes();
    } catch (e) {
      print('Erro ao carregar atividades pendentes: $e');
    }
  }

  Future<void> approveAtividade(String atividadeId) async {
    try {
      await _firestoreService.aprovarAtividade(atividadeId);
      _atividadesPendentes.removeWhere((a) => a.id == atividadeId);
      notifyListeners();
    } catch (e) {
      print('Erro ao aprovar atividade: $e');
    }
  }

  Future<void> _loadTotalParticipantes() async {
    try {
      _totalParticipantes = await _firestoreService.getTotalParticipantes();
    } catch (e) {
      print('Erro ao contar participantes: $e');
    }
  }

  Future<void> _loadTotalCheckins() async {
    try {
      _totalCheckins = await _firestoreService.getTotalCheckins();
    } catch (e) {
      print('Erro ao contar check-ins: $e');
    }
  }

  Future<void> _loadTotalPalestrantes() async {
    try {
      _totalPalestrantes = await _firestoreService.getTotalPalestrantes();
    } catch (e) {
      print('Erro ao contar palestrantes: $e');
    }
  }

  Future<void> _loadTotalPalestrantesAprovados() async {
    try {
      _totalPalestrantesAprovados = await _firestoreService.getTotalPalestrantesAprovados();
    } catch (e) {
      print('Erro ao contar palestrantes aprovados: $e');
    }
  }

  Future<void> approveSpeaker(String uid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.approveSpeaker(uid);
      await _loadPalestrantesPendentes();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rejectSpeaker(String uid, String motivo) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.rejectSpeaker(uid, motivo);
      await _loadPalestrantesPendentes();
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
      await _loadPerguntasPendentes();
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
      await _loadPerguntasPendentes();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendAviso({
    required String titulo,
    required String mensagem,
    required String tipo,
    required List<String> destinatarios,
    required String autorId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final aviso = AvisoModel(
        id: const Uuid().v4(),
        titulo: titulo,
        mensagem: mensagem,
        tipo: TipoAviso.values.firstWhere(
          (e) => e.toString().split('.').last == tipo,
        ),
        destinatarios: destinatarios,
        criadoEm: DateTime.now(),
        autorId: autorId,
      );

      await _firestoreService.createAviso(aviso);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allUsers = await _firestoreService.getAllUsers();
    } catch (e) {
      _error = e.toString();
      print('Erro ao carregar usuários: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> promoteUserToAdmin(String uid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.promoteUserToAdmin(uid);
      await loadAllUsers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> demoteAdminToUser(String uid, String novoTipo) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.demoteAdminToUser(uid, novoTipo);
      await loadAllUsers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
