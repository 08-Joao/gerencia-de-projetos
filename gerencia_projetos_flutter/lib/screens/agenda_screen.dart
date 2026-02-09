import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/agenda_provider.dart';
import '../providers/event_provider.dart';
import '../providers/user_provider.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({Key? key}) : super(key: key);

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAgenda();
    });
  }

  Future<void> _loadAgenda() async {
    final userProvider = context.read<UserProvider>();
    final agendaProvider = context.read<AgendaProvider>();

    if (userProvider.currentUser != null) {
      await agendaProvider.loadAgenda(userProvider.currentUser!.uid);
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
              final atividade = eventProvider.atividades.firstWhere(
                (a) => a.id == item.atividadeId,
                orElse: () => null as dynamic,
              );

              if (atividade == null) {
                return const SizedBox.shrink();
              }

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
      builder: (context) => AlertDialog(
        title: const Text('Remover da Agenda'),
        content: const Text('Deseja remover esta atividade de sua agenda?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await agendaProvider.removeFromAgenda(usuarioId, atividadeId);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Removido da agenda')),
                );
              }
            },
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}
