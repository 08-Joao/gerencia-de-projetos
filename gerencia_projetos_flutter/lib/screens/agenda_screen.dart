import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/agenda_provider.dart';
import '../providers/event_provider.dart';
import '../providers/user_provider.dart';
import '../services/firestore_service.dart';
import '../models/question_model.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({Key? key}) : super(key: key);

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  late FirestoreService _firestoreService;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAgenda();
    });
  }

  Future<void> _loadAgenda() async {
    final userProvider = context.read<UserProvider>();
    final agendaProvider = context.read<AgendaProvider>();
    final eventProvider = context.read<EventProvider>();

    if (userProvider.currentUser != null) {
      await agendaProvider.loadAgenda(userProvider.currentUser!.uid);
      await eventProvider.loadAtividades();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Agenda'),
        elevation: 0,
      ),
      body: Consumer3<AgendaProvider, EventProvider, UserProvider>(
        builder: (context, agendaProvider, eventProvider, userProvider, _) {
          if (agendaProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final agenda = agendaProvider.agenda;
          if (agenda.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sua agenda está vazia',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione atividades à sua agenda na programação',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: agenda.length,
            itemBuilder: (context, index) {
              final item = agenda[index];
              final atividadeIndex = eventProvider.atividades.indexWhere(
                (a) => a.id == item.atividadeId,
              );

              if (atividadeIndex == -1) {
                return const SizedBox.shrink();
              }

              final atividade = eventProvider.atividades[atividadeIndex];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  atividade.titulo,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  atividade.palestranteNome,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _removeFromAgenda(
                                context,
                                userProvider.currentUser!.uid,
                                atividade.id,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${atividade.horaInicio.hour}:${atividade.horaInicio.minute.toString().padLeft(2, '0')} - ${atividade.horaFim.hour}:${atividade.horaFim.minute.toString().padLeft(2, '0')}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              atividade.local,
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Lembrete: ${item.lembreteMinutos} minutos antes',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.blue,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showAskQuestionDialog(
                                context,
                                atividade.id,
                                userProvider.currentUser!.uid,
                                userProvider.currentUser!.nome,
                              ),
                              icon: const Icon(Icons.help_outline),
                              label: const Text('Fazer Pergunta'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showQuestionsDialog(
                                context,
                                atividade.id,
                              ),
                              icon: const Icon(Icons.comment),
                              label: const Text('Ver Perguntas'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _removeFromAgenda(
    BuildContext context,
    String usuarioId,
    String atividadeId,
  ) async {
    final agendaProvider = context.read<AgendaProvider>();

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Remover da Agenda',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              const Text('Deseja remover esta atividade de sua agenda?'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      await agendaProvider.removeFromAgenda(usuarioId, atividadeId);
                      if (mounted) {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Removido da agenda')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Remover'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAskQuestionDialog(
    BuildContext context,
    String atividadeId,
    String usuarioId,
    String usuarioNome,
  ) async {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fazer uma Pergunta',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  hintText: 'Digite sua pergunta...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      if (textController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Digite uma pergunta')),
                        );
                        return;
                      }

                      try {
                        final pergunta = PerguntaModel(
                          id: const Uuid().v4(),
                          atividadeId: atividadeId,
                          autorId: usuarioId,
                          autorNome: usuarioNome,
                          texto: textController.text,
                          status: StatusPergunta.pendente,
                          criadaEm: DateTime.now(),
                          respondida: false,
                        );

                        await _firestoreService.createPergunta(pergunta);
                        if (mounted) {
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Pergunta enviada para moderação')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erro ao enviar pergunta: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('Enviar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showQuestionsDialog(
    BuildContext context,
    String atividadeId,
  ) async {
    try {
      final perguntas = await _firestoreService.getPerguntasByAtividade(atividadeId);
      final perguntasAprovadas = perguntas
          .where((p) => p.status == StatusPergunta.aprovada)
          .toList();

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (dialogContext) => Dialog(
          insetPadding: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Perguntas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: perguntasAprovadas.isEmpty
                      ? const Center(
                          child: Text('Nenhuma pergunta aprovada ainda'),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: perguntasAprovadas.length,
                          itemBuilder: (context, index) {
                            final pergunta = perguntasAprovadas[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pergunta.autorNome,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[600],
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    pergunta.texto,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  if (index < perguntasAprovadas.length - 1)
                                    Divider(color: Colors.grey[300]),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Fechar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar perguntas: $e')),
        );
      }
    }
  }
}
