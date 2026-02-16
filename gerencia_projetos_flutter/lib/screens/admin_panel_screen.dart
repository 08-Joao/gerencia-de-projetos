import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    final adminProvider = context.read<AdminProvider>();
    
    await adminProvider.loadDashboardData();
    await adminProvider.loadAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Administrativo'),
        elevation: 0,
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          if (adminProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildTabBar(),
              Expanded(
                child: _buildTabContent(adminProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.grey[100],
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTab(0, 'Dashboard'),
            _buildTab(1, 'Atividades'),
            _buildTab(2, 'Palestrantes'),
            _buildTab(3, 'Perguntas'),
            _buildTab(4, 'Avisos'),
            _buildTab(5, 'Admins'),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.blue : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(AdminProvider adminProvider) {
    switch (_selectedTab) {
      case 0:
        return _buildDashboard(adminProvider);
      case 1:
        return _buildAtividadesTab(adminProvider);
      case 2:
        return _buildSpeakersTab(adminProvider);
      case 3:
        return _buildQuestionsTab(adminProvider);
      case 4:
        return _buildNoticesTab();
      case 5:
        return _buildAdminManagementTab(adminProvider);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDashboard(AdminProvider adminProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estatísticas',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Participantes',
                  adminProvider.totalParticipantes.toString(),
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Check-ins',
                  adminProvider.totalCheckins.toString(),
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Palestrantes Total',
                  adminProvider.totalPalestrantes.toString(),
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Palestrantes Aprovados',
                  adminProvider.totalPalestrantesAprovados.toString(),
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Palestrantes Pendentes',
                  adminProvider.palestrantesPendentes.length.toString(),
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Perguntas Pendentes',
                  adminProvider.perguntasPendentes.length.toString(),
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAtividadesTab(AdminProvider adminProvider) {
    final atividades = adminProvider.atividadesPendentes;

    if (atividades.isEmpty) {
      return Center(
        child: Text(
          'Nenhuma atividade pendente de aprovação',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: atividades.length,
      itemBuilder: (context, index) {
        final atividade = atividades[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  atividade.titulo,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Palestrante: ${atividade.palestranteNome}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tipo: ${atividade.tipo.toString().split('.').last}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Data: ${atividade.data.day}/${atividade.data.month}/${atividade.data.year}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  atividade.descricao,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => _approveAtividade(context, adminProvider, atividade.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Aprovar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _approveAtividade(
    BuildContext context,
    AdminProvider adminProvider,
    String atividadeId,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    await adminProvider.approveAtividade(atividadeId);
    if (mounted) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Atividade aprovada com sucesso')),
      );
    }
  }

  Widget _buildSpeakersTab(AdminProvider adminProvider) {
    final palestrantes = adminProvider.palestrantesPendentes;

    if (palestrantes.isEmpty) {
      return Center(
        child: Text(
          'Nenhum palestrante pendente',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: palestrantes.length,
      itemBuilder: (context, index) {
        final palestrante = palestrantes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  palestrante.nome,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  palestrante.email,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                if (palestrante.bio != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    palestrante.bio!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => _rejectSpeaker(context, adminProvider, palestrante.uid),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Recusar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _approveSpeaker(context, adminProvider, palestrante.uid),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Aprovar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionsTab(AdminProvider adminProvider) {
    final perguntas = adminProvider.perguntasPendentes;

    if (perguntas.isEmpty) {
      return Center(
        child: Text(
          'Nenhuma pergunta pendente',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: perguntas.length,
      itemBuilder: (context, index) {
        final pergunta = perguntas[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pergunta.autorNome,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  pergunta.texto,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => _rejectQuestion(context, adminProvider, pergunta.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Recusar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _approveQuestion(context, adminProvider, pergunta.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Aprovar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoticesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enviar Aviso',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildNoticeForm(),
        ],
      ),
    );
  }

  Widget _buildNoticeForm() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String selectedType = 'normal';

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: messageController,
              decoration: InputDecoration(
                labelText: 'Mensagem',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: InputDecoration(
                labelText: 'Tipo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'normal', child: Text('Normal')),
                DropdownMenuItem(value: 'urgente', child: Text('Urgente')),
                DropdownMenuItem(value: 'informativo', child: Text('Informativo')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedType = value ?? 'normal';
                });
              },
            ),
            const SizedBox(height: 16),
            Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _sendNotice(
                      context,
                      titleController.text,
                      messageController.text,
                      selectedType,
                      userProvider.currentUser!.uid,
                    ),
                    child: const Text('Enviar Aviso'),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _approveSpeaker(
    BuildContext context,
    AdminProvider adminProvider,
    String uid,
  ) async {
    await adminProvider.approveSpeaker(uid);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Palestrante aprovado')),
      );
    }
  }

  Future<void> _rejectSpeaker(
    BuildContext context,
    AdminProvider adminProvider,
    String uid,
  ) async {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final motivoController = TextEditingController();
        return Dialog(
          insetPadding: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recusar Palestrante',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: motivoController,
                  decoration: InputDecoration(
                    labelText: 'Motivo da recusa',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
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
                        await adminProvider.rejectSpeaker(uid, motivoController.text);
                        if (mounted) {
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Palestrante recusado')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Recusar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _approveQuestion(
    BuildContext context,
    AdminProvider adminProvider,
    String perguntaId,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    await adminProvider.approvePergunta(perguntaId);
    if (mounted) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Pergunta aprovada')),
      );
    }
  }

  Future<void> _rejectQuestion(
    BuildContext context,
    AdminProvider adminProvider,
    String perguntaId,
  ) async {
    showDialog(
      context: context,
      builder: (context) {
        final motivoController = TextEditingController();
        return AlertDialog(
          title: const Text('Recusar Pergunta'),
          content: TextField(
            controller: motivoController,
            decoration: const InputDecoration(
              labelText: 'Motivo da recusa',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                await adminProvider.rejectPergunta(perguntaId, motivoController.text);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pergunta recusada')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Recusar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendNotice(
    BuildContext context,
    String titulo,
    String mensagem,
    String tipo,
    String autorId,
  ) async {
    final adminProvider = context.read<AdminProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (titulo.isEmpty || mensagem.isEmpty) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    try {
      await adminProvider.sendAviso(
        titulo: titulo,
        mensagem: mensagem,
        tipo: tipo,
        destinatarios: ['todos'],
        autorId: autorId,
      );

      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Aviso enviado com sucesso')),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Erro ao enviar aviso: $e')),
        );
      }
    }
  }

  Widget _buildAdminManagementTab(AdminProvider adminProvider) {
    final users = adminProvider.allUsers;
    if (users.isEmpty) {
      return Center(
        child: Text(
          'Nenhum usuário encontrado',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isAdmin = user.tipo == UserType.admin;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.nome,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isAdmin ? Colors.red.shade100 : Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isAdmin ? 'Admin' : user.tipo.toString().split('.').last,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isAdmin ? Colors.red : Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isAdmin)
                      ElevatedButton.icon(
                        onPressed: () => _demoteAdmin(context, adminProvider, user),
                        icon: const Icon(Icons.remove_circle, size: 18),
                        label: const Text('Remover'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () => _promoteToAdmin(context, adminProvider, user),
                        icon: const Icon(Icons.add_circle, size: 18),
                        label: const Text('Tornar Admin'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
  }

  Future<void> _promoteToAdmin(
    BuildContext context,
    AdminProvider adminProvider,
    dynamic user,
  ) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Promoção'),
        content: Text('Deseja tornar ${user.nome} um administrador?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await adminProvider.promoteUserToAdmin(user.uid);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${user.nome} agora é um administrador')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Future<void> _demoteAdmin(
    BuildContext context,
    AdminProvider adminProvider,
    dynamic user,
  ) async {
    showDialog(
      context: context,
      builder: (context) {
        String selectedType = 'participante';
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Remover Privilégios de Admin'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Rebaixar ${user.nome} para qual tipo de usuário?'),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Usuário',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'participante', child: Text('Participante')),
                    DropdownMenuItem(value: 'palestrante', child: Text('Palestrante')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedType = value ?? 'participante';
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await adminProvider.demoteAdminToUser(user.uid, selectedType);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${user.nome} foi rebaixado para $selectedType')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Confirmar'),
              ),
            ],
          ),
        );
      },
    );
  }
}
