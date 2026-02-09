import 'package:cloud_firestore/cloud_firestore.dart';

enum TipoNotificacao {
  avisoGeral,
  lembrete,
  mudancaProgramacao,
  respostaPergunta,
  aprovacaoPalestrante,
  recusaoPalestrante,
}

class NotificacaoModel {
  final String id;
  final TipoNotificacao tipo;
  final String titulo;
  final String mensagem;
  final bool lida;
  final DateTime criadaEm;
  final String? referenciaId;

  NotificacaoModel({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.mensagem,
    required this.lida,
    required this.criadaEm,
    this.referenciaId,
  });

  factory NotificacaoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificacaoModel(
      id: doc.id,
      tipo: TipoNotificacao.values.firstWhere(
        (e) => e.toString().split('.').last == data['tipo'],
        orElse: () => TipoNotificacao.avisoGeral,
      ),
      titulo: data['titulo'] ?? '',
      mensagem: data['mensagem'] ?? '',
      lida: data['lida'] ?? false,
      criadaEm: (data['criadaEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
      referenciaId: data['referenciaId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tipo': tipo.toString().split('.').last,
      'titulo': titulo,
      'mensagem': mensagem,
      'lida': lida,
      'criadaEm': Timestamp.fromDate(criadaEm),
      'referenciaId': referenciaId,
    };
  }

  NotificacaoModel copyWith({
    String? id,
    TipoNotificacao? tipo,
    String? titulo,
    String? mensagem,
    bool? lida,
    DateTime? criadaEm,
    String? referenciaId,
  }) {
    return NotificacaoModel(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      titulo: titulo ?? this.titulo,
      mensagem: mensagem ?? this.mensagem,
      lida: lida ?? this.lida,
      criadaEm: criadaEm ?? this.criadaEm,
      referenciaId: referenciaId ?? this.referenciaId,
    );
  }
}
