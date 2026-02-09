import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  UsuarioModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UsuarioModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isAdmin => _currentUser?.tipo == UserType.admin;
  bool get isPalestrante => _currentUser?.tipo == UserType.palestrante;
  bool get isParticipante => _currentUser?.tipo == UserType.participante;
  bool get isPalestranteAprovado =>
      _currentUser?.tipo == UserType.palestrante &&
      _currentUser?.status == UserStatus.ativo;

  Future<void> loadCurrentUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authService.getCurrentUserData();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String nome,
    required String instituicao,
    required bool isPalestrante,
    required String? bio,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signUp(
        email: email,
        password: password,
        nome: nome,
        instituicao: instituicao,
        isPalestrante: isPalestrante,
        bio: bio,
      );
      await loadCurrentUser();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signIn(email: email, password: password);
      await loadCurrentUser();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signOut();
      _currentUser = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String nome,
    required String? fotoPerfil,
    required String? instituicao,
    String? matricula,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.updateUserProfile(
        uid: _currentUser!.uid,
        nome: nome,
        fotoPerfil: fotoPerfil,
        instituicao: instituicao,
        matricula: matricula,
      );
      await loadCurrentUser();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
