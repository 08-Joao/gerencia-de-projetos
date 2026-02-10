import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/user_provider.dart';
import '../providers/event_provider.dart';
import '../models/activity_model.dart';
import '../services/firestore_service.dart';

class SpeakerManagementScreen extends StatefulWidget {
  const SpeakerManagementScreen({Key? key}) : super(key: key);

  @override
  State<SpeakerManagementScreen> createState() =>
      _SpeakerManagementScreenState();
}

class _SpeakerManagementScreenState extends State<SpeakerManagementScreen> {
  late FirestoreService _firestoreService;
  List<AtividadeModel> _minhasPalestras = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final eventProvider = context.read<EventProvider>();
    if (eventProvider.eventoAtual == null) {
      await eventProvider.loadEventos();
    }
    await _loadMinhasPalestras();
  }

  Future<void> _loadMinhasPalestras() async {
    final userProvider = context.read<UserProvider>();
    if (userProvider.currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      _minhasPalestras = await _firestoreService
          .getAtividadesByPalestrante(userProvider.currentUser!.uid);
    } catch (e) {
      print('Erro ao carregar palestras: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Palestras'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateActivityDialog();
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _minhasPalestras.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.slideshow,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma palestra cadastrada',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Clique no + para criar uma nova',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _minhasPalestras.length,
                  itemBuilder: (context, index) {
                    final palestra = _minhasPalestras[index];
                    return _buildPalestraCard(context, palestra);
                  },
                ),
    );
  }

  Widget _buildPalestraCard(BuildContext context, AtividadeModel palestra) {
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
                        palestra.titulo,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Chip(
                        label: Text(
                          palestra.publicada ? 'Publicada' : 'Rascunho',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: palestra.publicada
                            ? Colors.green.shade100
                            : Colors.orange.shade100,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Editar'),
                      onTap: () => _showEditActivityDialog(palestra),
                    ),
                    PopupMenuItem(
                      child: const Text('Deletar'),
                      onTap: () => _deleteActivity(palestra.id),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              palestra.descricao,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
                  '${palestra.horaInicio.hour}:${palestra.horaInicio.minute.toString().padLeft(2, '0')} - ${palestra.horaFim.hour}:${palestra.horaFim.minute.toString().padLeft(2, '0')}',
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
                    palestra.local,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateActivityDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => _ActivityFormDialog(
        onSave: (atividade) async {
          try {
            await _firestoreService.createAtividade(atividade);
            if (mounted) {
              Navigator.pop(dialogContext);
              await _loadMinhasPalestras();
              final eventProvider = context.read<EventProvider>();
              await eventProvider.loadAtividades(atividade.eventoId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Palestra criada com sucesso')),
                );
              }
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao criar palestra: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showEditActivityDialog(AtividadeModel atividade) {
    showDialog(
      context: context,
      builder: (context) => _ActivityFormDialog(
        initialActivity: atividade,
        onSave: (atividadeAtualizada) async {
          await _firestoreService.updateAtividade(atividadeAtualizada);
          await _loadMinhasPalestras();
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Palestra atualizada com sucesso')),
            );
          }
        },
      ),
    );
  }

  Future<void> _deleteActivity(String atividadeId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Palestra'),
        content: const Text('Tem certeza que deseja deletar esta palestra?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
  }
}

class _ActivityFormDialog extends StatefulWidget {
  final AtividadeModel? initialActivity;
  final Function(AtividadeModel) onSave;

  const _ActivityFormDialog({
    Key? key,
    this.initialActivity,
    required this.onSave,
  }) : super(key: key);

  @override
  State<_ActivityFormDialog> createState() => _ActivityFormDialogState();
}

class _ActivityFormDialogState extends State<_ActivityFormDialog> {
  late TextEditingController _tituloController;
  late TextEditingController _descricaoController;
  late TextEditingController _localController;
  late TextEditingController _tagsController;
  late DateTime _dataInicio;
  late DateTime _dataFim;
  late TimeOfDay _horaInicio;
  late TimeOfDay _horaFim;
  String _tipoSelecionado = 'palestra';
  bool _publicada = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialActivity != null) {
      _tituloController =
          TextEditingController(text: widget.initialActivity!.titulo);
      _descricaoController =
          TextEditingController(text: widget.initialActivity!.descricao);
      _localController =
          TextEditingController(text: widget.initialActivity!.local);
      _tagsController =
          TextEditingController(text: widget.initialActivity!.tags.join(', '));
      _dataInicio = widget.initialActivity!.data;
      _dataFim = widget.initialActivity!.data;
      _horaInicio = TimeOfDay.fromDateTime(widget.initialActivity!.horaInicio);
      _horaFim = TimeOfDay.fromDateTime(widget.initialActivity!.horaFim);
      _tipoSelecionado = widget.initialActivity!.tipo.toString().split('.').last;
      _publicada = widget.initialActivity!.publicada;
    } else {
      _tituloController = TextEditingController();
      _descricaoController = TextEditingController();
      _localController = TextEditingController();
      _tagsController = TextEditingController();
      _dataInicio = DateTime.now();
      _dataFim = DateTime.now();
      _horaInicio = TimeOfDay.now();
      _horaFim = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);
      _publicada = true;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _localController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.initialActivity == null ? 'Nova Palestra' : 'Editar Palestra',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _tituloController,
                      decoration: InputDecoration(
                        labelText: 'Título',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descricaoController,
                      decoration: InputDecoration(
                        labelText: 'Descrição',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _localController,
                      decoration: InputDecoration(
                        labelText: 'Local/Sala',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _tipoSelecionado,
                      decoration: InputDecoration(
                        labelText: 'Tipo',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'palestra', child: Text('Palestra')),
                        DropdownMenuItem(value: 'minicurso', child: Text('Minicurso')),
                        DropdownMenuItem(value: 'workshop', child: Text('Workshop')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _tipoSelecionado = value ?? 'palestra';
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _dataInicio,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (date != null) {
                                setState(() {
                                  _dataInicio = date;
                                  _dataFim = date;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Data',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                '${_dataInicio.day}/${_dataInicio.month}/${_dataInicio.year}',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: _horaInicio,
                              );
                              if (time != null) {
                                setState(() {
                                  _horaInicio = time;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Hora Início',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                '${_horaInicio.hour.toString().padLeft(2, '0')}:${_horaInicio.minute.toString().padLeft(2, '0')}',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: _horaFim,
                              );
                              if (time != null) {
                                setState(() {
                                  _horaFim = time;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Hora Fim',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                '${_horaFim.hour.toString().padLeft(2, '0')}:${_horaFim.minute.toString().padLeft(2, '0')}',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _tagsController,
                      decoration: InputDecoration(
                        labelText: 'Tags (separadas por vírgula)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      title: const Text('Publicada'),
                      value: _publicada,
                      onChanged: (value) {
                        setState(() {
                          _publicada = value ?? false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _saveActivity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveActivity() {
    final userProvider = context.read<UserProvider>();
    final eventProvider = context.read<EventProvider>();

    if (_tituloController.text.isEmpty ||
        _descricaoController.text.isEmpty ||
        _localController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios')),
      );
      return;
    }

    if (eventProvider.eventoAtual == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum evento disponível. Tente novamente.')),
      );
      return;
    }

    final horaInicio = DateTime(
      _dataInicio.year,
      _dataInicio.month,
      _dataInicio.day,
      _horaInicio.hour,
      _horaInicio.minute,
    );

    final horaFim = DateTime(
      _dataFim.year,
      _dataFim.month,
      _dataFim.day,
      _horaFim.hour,
      _horaFim.minute,
    );

    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final atividade = AtividadeModel(
      id: widget.initialActivity?.id ?? const Uuid().v4(),
      eventoId: eventProvider.eventoAtual!.id,
      titulo: _tituloController.text,
      descricao: _descricaoController.text,
      palestranteId: userProvider.currentUser!.uid,
      palestranteNome: userProvider.currentUser!.nome,
      data: _dataInicio,
      horaInicio: horaInicio,
      horaFim: horaFim,
      local: _localController.text,
      tipo: TipoAtividade.values.firstWhere(
        (e) => e.toString().split('.').last == _tipoSelecionado,
      ),
      tags: tags,
      capacidade: null,
      publicada: widget.initialActivity == null ? true : _publicada,
      materialApoio: null,
    );

    widget.onSave(atividade);
  }
}
