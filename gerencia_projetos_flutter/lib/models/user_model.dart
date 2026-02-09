import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType { participante, palestrante, admin }

enum UserStatus { ativo, pendente, recusado }

class UsuarioModel {
  final String uid;
  final String email;
  final String nome;
  final UserType tipo;
  final UserStatus status;
  final String? fotoPerfil;
  final String? instituicao;
  final String? matricula;
  final String? bio;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  UsuarioModel({
    required this.uid,
    required this.email,
    required this.nome,
    required this.tipo,
    required this.status,
    this.fotoPerfil,
    this.instituicao,
    this.matricula,
    this.bio,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  factory UsuarioModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    UserType _parseUserType(dynamic value) {
      if (value == null) return UserType.participante;
      final typeStr = value.toString().toLowerCase();
      for (final type in UserType.values) {
        if (type.toString().split('.').last == typeStr) {
          return type;
        }
      }
      return UserType.participante;
    }
    
    UserStatus _parseUserStatus(dynamic value) {
      if (value == null) return UserStatus.ativo;
      final statusStr = value.toString().toLowerCase();
      for (final status in UserStatus.values) {
        if (status.toString().split('.').last == statusStr) {
          return status;
        }
      }
      return UserStatus.ativo;
    }
    
    return UsuarioModel(
      uid: doc.id,
      email: data['email'] ?? '',
      nome: data['nome'] ?? '',
      tipo: _parseUserType(data['tipo']),
      status: _parseUserStatus(data['status']),
      fotoPerfil: data['fotoPerfil'],
      instituicao: data['instituicao'],
      matricula: data['matricula'],
      bio: data['bio'],
      criadoEm: (data['criadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
      atualizadoEm: (data['atualizadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'nome': nome,
      'tipo': tipo.toString().split('.').last,
      'status': status.toString().split('.').last,
      'fotoPerfil': fotoPerfil,
      'instituicao': instituicao,
      'matricula': matricula,
      'bio': bio,
      'criadoEm': Timestamp.fromDate(criadoEm),
      'atualizadoEm': Timestamp.fromDate(atualizadoEm),
    };
  }

  UsuarioModel copyWith({
    String? uid,
    String? email,
    String? nome,
    UserType? tipo,
    UserStatus? status,
    String? fotoPerfil,
    String? instituicao,
    String? matricula,
    String? bio,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return UsuarioModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      status: status ?? this.status,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      instituicao: instituicao ?? this.instituicao,
      matricula: matricula ?? this.matricula,
      bio: bio ?? this.bio,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }
}
