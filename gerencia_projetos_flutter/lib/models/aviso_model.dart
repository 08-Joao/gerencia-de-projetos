import 'package:cloud_firestore/cloud_firestore.dart';

enum TipoAviso { urgente, normal, informativo }

class AvisoModel {
  final String id;
  final String titulo;
  final String mensagem;
  final TipoAviso tipo;
  final List<String> destinatarios;
  final DateTime criadoEm;
  final String autorId;

  AvisoModel({
    required this.id,
    required this.titulo,
    required this.mensagem,
    required this.tipo,
    required this.destinatarios,
    required this.criadoEm,
    required this.autorId,
  });

  factory AvisoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AvisoModel(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      mensagem: data['mensagem'] ?? '',
      tipo: TipoAviso.values.firstWhere(
        (e) => e.toString().split('.').last == data['tipo'],
        orElse: () => TipoAviso.normal,
      ),
      destinatarios: List<String>.from(data['destinatarios'] ?? []),
      criadoEm: (data['criadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
      autorId: data['autorId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'titulo': titulo,
      'mensagem': mensagem,
      'tipo': tipo.toString().split('.').last,
      'destinatarios': destinatarios,
      'criadoEm': Timestamp.fromDate(criadoEm),
      'autorId': autorId,
    };
  }
}
