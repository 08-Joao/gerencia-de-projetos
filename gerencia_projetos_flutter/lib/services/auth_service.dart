import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UsuarioModel?> getCurrentUserData() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      return UsuarioModel.fromFirestore(doc);
    } catch (e) {
      print('Erro ao obter dados do usuário: $e');
      return null;
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
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      final userData = UsuarioModel(
        uid: uid,
        email: email,
        nome: nome,
        tipo: isPalestrante ? UserType.palestrante : UserType.participante,
        status: isPalestrante ? UserStatus.pendente : UserStatus.ativo,
        instituicao: instituicao,
        bio: bio,
        fotoPerfil: null,
        criadoEm: DateTime.now(),
        atualizadoEm: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(userData.toFirestore());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw 'A senha é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        throw 'Este email já está registrado.';
      } else {
        throw 'Erro ao criar conta: ${e.message}';
      }
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'Usuário não encontrado.';
      } else if (e.code == 'wrong-password') {
        throw 'Senha incorreta.';
      } else {
        throw 'Erro ao fazer login: ${e.message}';
      }
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw 'Erro ao fazer logout: $e';
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw 'Erro ao enviar email de recuperação: $e';
    }
  }

  Future<void> updateUserProfile({
    required String uid,
    required String nome,
    required String? fotoPerfil,
    required String? instituicao,
    String? matricula,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'nome': nome,
        'fotoPerfil': fotoPerfil,
        'instituicao': instituicao,
        'matricula': matricula,
        'atualizadoEm': Timestamp.now(),
      });
    } catch (e) {
      throw 'Erro ao atualizar perfil: $e';
    }
  }

  Future<void> approveSpeaker(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'status': 'ativo',
        'atualizadoEm': Timestamp.now(),
      });
    } catch (e) {
      throw 'Erro ao aprovar palestrante: $e';
    }
  }

  Future<void> rejectSpeaker(String uid, String motivo) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'status': 'recusado',
        'motivoRecusa': motivo,
        'atualizadoEm': Timestamp.now(),
      });
    } catch (e) {
      throw 'Erro ao recusar palestrante: $e';
    }
  }
}
