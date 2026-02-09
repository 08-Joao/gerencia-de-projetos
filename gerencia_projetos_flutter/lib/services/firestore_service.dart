import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity_model.dart';
import '../models/event_model.dart';
import '../models/question_model.dart';
import '../models/checkin_model.dart';
import '../models/agenda_model.dart';
import '../models/aviso_model.dart';
import '../models/notificacao_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== EVENTOS =====
  Future<List<EventoModel>> getEventos() async {
    try {
      final snapshot = await _firestore
          .collection('eventos')
          .where('ativo', isEqualTo: true)
          .get();
      return snapshot.docs.map((doc) => EventoModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Erro ao buscar eventos: $e');
      return [];
    }
  }

  Future<EventoModel?> getEventoById(String eventoId) async {
    try {
      final doc = await _firestore.collection('eventos').doc(eventoId).get();
      if (!doc.exists) return null;
      return EventoModel.fromFirestore(doc);
    } catch (e) {
      print('Erro ao buscar evento: $e');
      return null;
    }
  }

  Future<void> createEvento(EventoModel evento) async {
    try {
      await _firestore.collection('eventos').doc(evento.id).set(evento.toFirestore());
    } catch (e) {
      throw 'Erro ao criar evento: $e';
    }
  }

  // ===== ATIVIDADES =====
  Future<List<AtividadeModel>> getAtividadesByEvento(String eventoId) async {
    try {
      final snapshot = await _firestore
          .collection('atividades')
          .where('eventoId', isEqualTo: eventoId)
          .where('publicada', isEqualTo: true)
          .orderBy('data')
          .orderBy('horaInicio')
          .get();
      return snapshot.docs.map((doc) => AtividadeModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Erro ao buscar atividades: $e');
      return [];
    }
  }

  Future<AtividadeModel?> getAtividadeById(String atividadeId) async {
    try {
      final doc = await _firestore.collection('atividades').doc(atividadeId).get();
      if (!doc.exists) return null;
      return AtividadeModel.fromFirestore(doc);
    } catch (e) {
      print('Erro ao buscar atividade: $e');
      return null;
    }
  }

  Future<void> createAtividade(AtividadeModel atividade) async {
    try {
      await _firestore
          .collection('atividades')
          .doc(atividade.id)
          .set(atividade.toFirestore());
    } catch (e) {
      throw 'Erro ao criar atividade: $e';
    }
  }

  Future<void> updateAtividade(AtividadeModel atividade) async {
    try {
      await _firestore
          .collection('atividades')
          .doc(atividade.id)
          .update(atividade.toFirestore());
    } catch (e) {
      throw 'Erro ao atualizar atividade: $e';
    }
  }

  Future<List<AtividadeModel>> getAtividadesByPalestrante(String palestranteId) async {
    try {
      final snapshot = await _firestore
          .collection('atividades')
          .where('palestranteId', isEqualTo: palestranteId)
          .get();
      final atividades = snapshot.docs.map((doc) => AtividadeModel.fromFirestore(doc)).toList();
      atividades.sort((a, b) => a.data.compareTo(b.data));
      return atividades;
    } catch (e) {
      print('Erro ao buscar atividades do palestrante: $e');
      return [];
    }
  }

  // ===== CHECK-IN =====
  Future<void> createCheckin(CheckinModel checkin) async {
    try {
      await _firestore
          .collection('checkins')
          .doc(checkin.id)
          .set(checkin.toFirestore());
    } catch (e) {
      throw 'Erro ao realizar check-in: $e';
    }
  }

  Future<bool> hasCheckinInEvent(String usuarioId, String eventoId) async {
    try {
      final snapshot = await _firestore
          .collection('checkins')
          .where('usuarioId', isEqualTo: usuarioId)
          .where('eventoId', isEqualTo: eventoId)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Erro ao verificar check-in: $e');
      return false;
    }
  }

  // ===== AGENDA =====
  Future<void> addToAgenda(String usuarioId, ItemAgendaModel item) async {
    try {
      await _firestore
          .collection('agendas')
          .doc(usuarioId)
          .collection('atividades')
          .doc(item.atividadeId)
          .set(item.toFirestore());
    } catch (e) {
      throw 'Erro ao adicionar à agenda: $e';
    }
  }

  Future<void> removeFromAgenda(String usuarioId, String atividadeId) async {
    try {
      await _firestore
          .collection('agendas')
          .doc(usuarioId)
          .collection('atividades')
          .doc(atividadeId)
          .delete();
    } catch (e) {
      throw 'Erro ao remover da agenda: $e';
    }
  }

  Future<List<ItemAgendaModel>> getAgenda(String usuarioId) async {
    try {
      final snapshot = await _firestore
          .collection('agendas')
          .doc(usuarioId)
          .collection('atividades')
          .get();
      return snapshot.docs.map((doc) => ItemAgendaModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Erro ao buscar agenda: $e');
      return [];
    }
  }

  Future<bool> isInAgenda(String usuarioId, String atividadeId) async {
    try {
      final doc = await _firestore
          .collection('agendas')
          .doc(usuarioId)
          .collection('atividades')
          .doc(atividadeId)
          .get();
      return doc.exists;
    } catch (e) {
      print('Erro ao verificar agenda: $e');
      return false;
    }
  }

  // ===== PERGUNTAS =====
  Future<void> createPergunta(PerguntaModel pergunta) async {
    try {
      await _firestore
          .collection('perguntas')
          .doc(pergunta.id)
          .set(pergunta.toFirestore());
    } catch (e) {
      throw 'Erro ao enviar pergunta: $e';
    }
  }

  Future<List<PerguntaModel>> getPerguntasByAtividade(String atividadeId) async {
    try {
      final snapshot = await _firestore
          .collection('perguntas')
          .where('atividadeId', isEqualTo: atividadeId)
          .where('status', isEqualTo: 'aprovada')
          .orderBy('criadaEm', descending: true)
          .get();
      return snapshot.docs.map((doc) => PerguntaModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Erro ao buscar perguntas: $e');
      return [];
    }
  }

  Future<List<PerguntaModel>> getPerguntasPendentes() async {
    try {
      final snapshot = await _firestore
          .collection('perguntas')
          .where('status', isEqualTo: 'pendente')
          .get();
      final perguntas = snapshot.docs.map((doc) => PerguntaModel.fromFirestore(doc)).toList();
      perguntas.sort((a, b) => a.criadaEm.compareTo(b.criadaEm));
      return perguntas;
    } catch (e) {
      print('Erro ao buscar perguntas pendentes: $e');
      return [];
    }
  }

  Future<void> approvePergunta(String perguntaId) async {
    try {
      await _firestore.collection('perguntas').doc(perguntaId).update({
        'status': 'aprovada',
        'moderadaEm': Timestamp.now(),
      });
    } catch (e) {
      throw 'Erro ao aprovar pergunta: $e';
    }
  }

  Future<void> rejectPergunta(String perguntaId, String motivo) async {
    try {
      await _firestore.collection('perguntas').doc(perguntaId).update({
        'status': 'recusada',
        'motivoRecusa': motivo,
        'moderadaEm': Timestamp.now(),
      });
    } catch (e) {
      throw 'Erro ao recusar pergunta: $e';
    }
  }

  Future<List<PerguntaModel>> getMinhasPerguntasByUsuario(String usuarioId) async {
    try {
      final snapshot = await _firestore
          .collection('perguntas')
          .where('autorId', isEqualTo: usuarioId)
          .orderBy('criadaEm', descending: true)
          .get();
      return snapshot.docs.map((doc) => PerguntaModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Erro ao buscar minhas perguntas: $e');
      return [];
    }
  }

  // ===== AVISOS =====
  Future<void> createAviso(AvisoModel aviso) async {
    try {
      await _firestore.collection('avisos').doc(aviso.id).set(aviso.toFirestore());
    } catch (e) {
      throw 'Erro ao criar aviso: $e';
    }
  }

  Future<List<AvisoModel>> getAvisos() async {
    try {
      final snapshot = await _firestore
          .collection('avisos')
          .orderBy('criadoEm', descending: true)
          .get();
      return snapshot.docs.map((doc) => AvisoModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Erro ao buscar avisos: $e');
      return [];
    }
  }

  // ===== NOTIFICAÇÕES =====
  Future<void> createNotificacao(String usuarioId, NotificacaoModel notificacao) async {
    try {
      await _firestore
          .collection('notificacoes')
          .doc(usuarioId)
          .collection('items')
          .doc(notificacao.id)
          .set(notificacao.toFirestore());
    } catch (e) {
      throw 'Erro ao criar notificação: $e';
    }
  }

  Future<List<NotificacaoModel>> getNotificacoes(String usuarioId) async {
    try {
      final snapshot = await _firestore
          .collection('notificacoes')
          .doc(usuarioId)
          .collection('items')
          .orderBy('criadaEm', descending: true)
          .limit(50)
          .get();
      return snapshot.docs.map((doc) => NotificacaoModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Erro ao buscar notificações: $e');
      return [];
    }
  }

  Future<void> markNotificacaoAsRead(String usuarioId, String notificacaoId) async {
    try {
      await _firestore
          .collection('notificacoes')
          .doc(usuarioId)
          .collection('items')
          .doc(notificacaoId)
          .update({'lida': true});
    } catch (e) {
      throw 'Erro ao marcar notificação como lida: $e';
    }
  }

  // ===== USUÁRIOS =====
  Future<List<UsuarioModel>> getPalestrantesPendentes() async {
    try {
      // First, get all users to debug
      final allUsers = await _firestore.collection('users').get();
      print('Total users in database: ${allUsers.docs.length}');
      for (var doc in allUsers.docs) {
        final data = doc.data();
        print('User: ${data['nome']}, tipo: ${data['tipo']}, status: ${data['status']}');
      }
      
      // Now query for pending speakers
      final snapshot = await _firestore
          .collection('users')
          .where('tipo', isEqualTo: 'palestrante')
          .where('status', isEqualTo: 'pendente')
          .get();
      print('Palestrantes pendentes encontrados: ${snapshot.docs.length}');
      for (var doc in snapshot.docs) {
        print('Palestrante pendente: ${doc.data()}');
      }
      return snapshot.docs.map((doc) => UsuarioModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Erro ao buscar palestrantes pendentes: $e');
      return [];
    }
  }

  Future<UsuarioModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UsuarioModel.fromFirestore(doc);
    } catch (e) {
      print('Erro ao buscar usuário: $e');
      return null;
    }
  }

  Future<int> getTotalParticipantes() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('tipo', isEqualTo: 'participante')
          .get();
      print('Total participantes: ${snapshot.docs.length}');
      return snapshot.docs.length;
    } catch (e) {
      print('Erro ao contar participantes: $e');
      return 0;
    }
  }

  Future<int> getTotalCheckins(String eventoId) async {
    try {
      final snapshot = await _firestore
          .collection('checkins')
          .where('eventoId', isEqualTo: eventoId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Erro ao contar check-ins: $e');
      return 0;
    }
  }

  Future<int> getTotalPalestrantes() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('tipo', isEqualTo: 'palestrante')
          .get();
      print('Total palestrantes: ${snapshot.docs.length}');
      for (var doc in snapshot.docs) {
        print('Palestrante: ${doc.data()}');
      }
      return snapshot.docs.length;
    } catch (e) {
      print('Erro ao contar palestrantes: $e');
      return 0;
    }
  }

  Future<int> getTotalPalestrantesAprovados() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('tipo', isEqualTo: 'palestrante')
          .where('status', isEqualTo: 'ativo')
          .get();
      print('Total palestrantes aprovados: ${snapshot.docs.length}');
      for (var doc in snapshot.docs) {
        print('Palestrante aprovado: ${doc.data()}');
      }
      return snapshot.docs.length;
    } catch (e) {
      print('Erro ao contar palestrantes aprovados: $e');
      return 0;
    }
  }

  Future<List<UsuarioModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) => UsuarioModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Erro ao buscar todos os usuários: $e');
      return [];
    }
  }

  Future<void> promoteUserToAdmin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'tipo': 'admin',
        'atualizadoEm': Timestamp.now(),
      });
    } catch (e) {
      throw 'Erro ao promover usuário para admin: $e';
    }
  }

  Future<void> demoteAdminToUser(String uid, String novoTipo) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'tipo': novoTipo,
        'atualizadoEm': Timestamp.now(),
      });
    } catch (e) {
      throw 'Erro ao remover privilégios de admin: $e';
    }
  }
}
