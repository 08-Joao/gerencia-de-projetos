import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createUserProfile({
    required String name,
    required String email,
    required String phone,
    String? institution,
    String? enrollment,
    String userType = 'participante',
  }) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        final status = userType == 'palestrante' ? 'pendente' : 'ativo';
        await _firestore.collection('users').doc(currentUser.uid).set({
          'uid': currentUser.uid,
          'nome': name,
          'email': email,
          'phone': phone,
          'instituicao': institution,
          'matricula': enrollment,
          'tipo': userType,
          'status': status,
          'criadoEm': FieldValue.serverTimestamp(),
          'atualizadoEm': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Erro ao criar perfil do usuário: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      throw Exception('Erro ao buscar perfil do usuário: $e');
    }
  }

  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        return await getUserProfile(currentUser.uid);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar perfil atual: $e');
    }
  }

  Future<void> updateUserProfile({
    required String name,
  }) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser.uid).update({
          'nome': name,
          'atualizadoEm': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Erro ao atualizar perfil: $e');
    }
  }
}
