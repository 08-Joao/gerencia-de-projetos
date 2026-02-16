import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../providers/agenda_provider.dart';
import '../providers/user_provider.dart';
import '../models/activity_model.dart';

class ProgrammingScreen extends StatefulWidget {
  const ProgrammingScreen({Key? key}) : super(key: key);

  @override
  State<ProgrammingScreen> createState() => _ProgrammingScreenState();
}

class _ProgrammingScreenState extends State<ProgrammingScreen> {
  String? _selectedTipo;
  String? _selectedTag;
  String? _selectedPalestrante;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reloadActivities();
    });
  }

  Future<void> _reloadActivities() async {
    final eventProvider = context.read<EventProvider>();
    await eventProvider.loadAtividades();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Programação do Evento'),
        elevation: 0,
      ),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, _) {
          if (eventProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildFilterBar(context, eventProvider),
              Expanded(
                child: _buildActivityList(eventProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, EventProvider eventProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtros',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('Palestra'),
                selected: _selectedTipo == 'palestra',
                onSelected: (selected) {
                  setState(() {
                    _selectedTipo = selected ? 'palestra' : null;
                    _selectedTag = null;
                    _selectedPalestrante = null;
                  });
                  if (selected) {
                    eventProvider.filterByTipo('palestra');
                  } else {
                    eventProvider.clearFilters();
                  }
                },
              ),
              FilterChip(
                label: const Text('Minicurso'),
                selected: _selectedTipo == 'minicurso',
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTipo = 'minicurso';
                    } else {
                      _selectedTipo = null;
                    }
                    _selectedTag = null;
                    _selectedPalestrante = null;
                  });
                  if (selected) {
                    eventProvider.filterByTipo('minicurso');
                  } else {
                    eventProvider.clearFilters();
                  }
                },
              ),
              FilterChip(
                label: const Text('Workshop'),
                selected: _selectedTipo == 'workshop',
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTipo = 'workshop';
                    } else {
                      _selectedTipo = null;
                    }
                    _selectedTag = null;
                    _selectedPalestrante = null;
                  });
                  if (selected) {
                    eventProvider.filterByTipo('workshop');
                  } else {
                    eventProvider.clearFilters();
                  }
                },
              ),
              if (_selectedTipo != null || _selectedTag != null || _selectedPalestrante != null)
                FilterChip(
                  label: const Text('Limpar'),
                  onSelected: (_) {
                    setState(() {
                      _selectedTipo = null;
                      _selectedTag = null;
                      _selectedPalestrante = null;
                    });
                    eventProvider.clearFilters();
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList(EventProvider eventProvider) {
    final atividades = eventProvider.atividades;

    if (atividades.isEmpty) {
      return const Center(
        child: Text('Nenhuma atividade encontrada'),
      );
    }

    final atividadesPorDia = <DateTime, List<AtividadeModel>>{};
    for (var atividade in atividades) {
      final data = DateTime(
        atividade.data.year,
        atividade.data.month,
        atividade.data.day,
      );
      atividadesPorDia.putIfAbsent(data, () => []).add(atividade);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: atividadesPorDia.length,
      itemBuilder: (context, index) {
        final data = atividadesPorDia.keys.toList()[index];
        final atividadesDodia = atividadesPorDia[data]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '${data.day}/${data.month}/${data.year}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ...atividadesDodia.map((atividade) {
              return _buildActivityCard(context, atividade);
            }).toList(),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Future<void> _subscribeToActivity(BuildContext context, AtividadeModel atividade) async {
    final userProvider = context.read<UserProvider>();
    final agendaProvider = context.read<AgendaProvider>();

    if (userProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você precisa estar logado para se inscrever')),
      );
      return;
    }

    try {
      await agendaProvider.addToAgenda(
        userProvider.currentUser!.uid,
        atividade.id,
        0,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Atividade adicionada à sua agenda!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao inscrever: $e')),
        );
      }
    }
  }

  Widget _buildActivityCard(BuildContext context, AtividadeModel atividade) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
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
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                Chip(
                  label: Text(
                    atividade.tipo.toString().split('.').last,
                    style: const TextStyle(fontSize: 12),
                  ),
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
                Text(
                  atividade.local,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            if (atividade.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: atividade.tags
                    .map((tag) => Chip(
                          label: Text(tag),
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
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
                              atividade.titulo,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Palestrante: ${atividade.palestranteNome}'),
                                  const SizedBox(height: 8),
                                  Text('Descrição: ${atividade.descricao}'),
                                  const SizedBox(height: 8),
                                  Text('Local: ${atividade.local}'),
                                  const SizedBox(height: 8),
                                  Text('Horário: ${atividade.horaInicio.hour}:${atividade.horaInicio.minute.toString().padLeft(2, '0')} - ${atividade.horaFim.hour}:${atividade.horaFim.minute.toString().padLeft(2, '0')}'),
                                  if (atividade.tags.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text('Tags: ${atividade.tags.join(', ')}'),
                                  ],
                                ],
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
                },
                child: const Text('Ver Detalhes'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _subscribeToActivity(context, atividade),
                icon: const Icon(Icons.add),
                label: const Text('Inscrever-se'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
