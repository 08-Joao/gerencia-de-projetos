import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/firestore_service.dart';
import '../models/notificacao_model.dart';
import '../models/aviso_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late FirestoreService _firestoreService;
  List<NotificacaoModel> _notificacoes = [];
  List<AvisoModel> _avisos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotificacoes();
    });
  }

  Future<void> _loadNotificacoes() async {
    final userProvider = context.read<UserProvider>();
    if (userProvider.currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final notificacoes = await _firestoreService
          .getNotificacoes(userProvider.currentUser!.uid);
      final avisos = await _firestoreService.getAvisos();
      
      setState(() {
        _notificacoes = notificacoes;
        _avisos = avisos;
      });
    } catch (e) {
      print('Erro ao carregar notificações: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final allItems = <dynamic>[..._avisos, ..._notificacoes];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avisos e Notificações'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : allItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma notificação',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: allItems.length,
                  itemBuilder: (context, index) {
                    final item = allItems[index];
                    if (item is AvisoModel) {
                      return _buildAvisoCard(context, item);
                    } else {
                      return _buildNotificationCard(context, item as NotificacaoModel);
                    }
                  },
                ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificacaoModel notificacao,
  ) {
    final tipoIconMap = {
      TipoNotificacao.avisoGeral: Icons.info,
      TipoNotificacao.lembrete: Icons.alarm,
      TipoNotificacao.mudancaProgramacao: Icons.event_note,
      TipoNotificacao.respostaPergunta: Icons.question_answer,
      TipoNotificacao.aprovacaoPalestrante: Icons.check_circle,
      TipoNotificacao.recusaoPalestrante: Icons.cancel,
    };

    final tipoCorMap = {
      TipoNotificacao.avisoGeral: Colors.blue,
      TipoNotificacao.lembrete: Colors.orange,
      TipoNotificacao.mudancaProgramacao: Colors.purple,
      TipoNotificacao.respostaPergunta: Colors.green,
      TipoNotificacao.aprovacaoPalestrante: Colors.green,
      TipoNotificacao.recusaoPalestrante: Colors.red,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: tipoCorMap[notificacao.tipo],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    tipoIconMap[notificacao.tipo],
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notificacao.titulo,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatarData(notificacao.criadaEm),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                if (!notificacao.lida)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              notificacao.mensagem,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvisoCard(BuildContext context, AvisoModel aviso) {
    final tipoCorMap = {
      TipoAviso.urgente: Colors.red,
      TipoAviso.normal: Colors.blue,
      TipoAviso.informativo: Colors.green,
    };

    final tipoIconMap = {
      TipoAviso.urgente: Icons.warning,
      TipoAviso.normal: Icons.info,
      TipoAviso.informativo: Icons.announcement,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: tipoCorMap[aviso.tipo],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    tipoIconMap[aviso.tipo],
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        aviso.titulo,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatarData(aviso.criadoEm),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              aviso.mensagem,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _formatarData(DateTime data) {
    final agora = DateTime.now();
    final diferenca = agora.difference(data);

    if (diferenca.inMinutes < 1) {
      return 'Agora';
    } else if (diferenca.inMinutes < 60) {
      return 'há ${diferenca.inMinutes} minutos';
    } else if (diferenca.inHours < 24) {
      return 'há ${diferenca.inHours} horas';
    } else if (diferenca.inDays < 7) {
      return 'há ${diferenca.inDays} dias';
    } else {
      return '${data.day}/${data.month}/${data.year}';
    }
  }
}
