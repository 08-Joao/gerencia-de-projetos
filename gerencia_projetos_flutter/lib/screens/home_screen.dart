import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/event_provider.dart';
import '../models/user_model.dart';
import 'programming_screen.dart';
import 'agenda_screen.dart';
import 'profile_screen.dart';
import 'admin_panel_screen.dart';
import 'speaker_management_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final userProvider = context.read<UserProvider>();
    final eventProvider = context.read<EventProvider>();

    if (userProvider.currentUser == null) {
      await userProvider.loadCurrentUser();
    }
    await eventProvider.loadAtividades();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        if (userProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = userProvider.currentUser;
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Erro ao carregar usuário')),
          );
        }

        final screens = _buildScreens(user);

        return Scaffold(
          body: screens[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            backgroundColor: Colors.white,
            elevation: 8,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey[600],
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Início',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'Programação',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.bookmark),
                label: 'Agenda',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: 'Avisos',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildScreens(UsuarioModel user) {
    return [
      _buildDashboard(user),
      const ProgrammingScreen(),
      const AgendaScreen(),
      const NotificationsScreen(),
      const ProfileScreen(),
    ];
  }

  Widget _buildDashboard(UsuarioModel user) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Bem-vindo, ${user.nome}!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              if (user.tipo == UserType.admin) ...[
                _buildAdminCard(context),
                const SizedBox(height: 24),
              ],
              if (user.tipo == UserType.palestrante) ...[
                _buildSpeakerCard(context, user),
                const SizedBox(height: 24),
              ],
              _buildQuickStats(context, user),
              const SizedBox(height: 24),
              _buildEventStats(context, eventProvider),
              const SizedBox(height: 24),
              _buildUserStats(context, user),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStats(BuildContext context, UsuarioModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Próximas Atividades',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Consumer<EventProvider>(
          builder: (context, eventProvider, _) {
            final atividades = eventProvider.atividades.take(3).toList();
            if (atividades.isEmpty) {
              return const Text('Nenhuma atividade disponível');
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: atividades.length,
              itemBuilder: (context, index) {
                final atividade = atividades[index];
                final horaInicio = '${atividade.horaInicio.hour.toString().padLeft(2, '0')}:${atividade.horaInicio.minute.toString().padLeft(2, '0')}';
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(atividade.titulo),
                    subtitle: Text('${atividade.palestranteNome} • $horaInicio'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ActivityDetailScreen(atividade: atividade),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSpeakerCard(BuildContext context, UsuarioModel user) {
    final isApproved = user.status == UserStatus.ativo;
    
    return Card(
      color: isApproved ? Colors.blue.shade50 : Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gerenciar Palestras',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isApproved ? null : Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              isApproved
                  ? 'Acesse o painel de palestrante para gerenciar suas atividades'
                  : 'Sua conta está pendente de aprovação. Você poderá acessar o painel após ser aprovado.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isApproved ? null : Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isApproved
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SpeakerManagementScreen(),
                          ),
                        );
                      }
                    : null,
                child: Text(
                  isApproved ? 'Acessar Painel' : 'Pendente de Aprovação',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Painel Administrativo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gerenciar evento, aprovar palestrantes e moderar conteúdo',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminPanelScreen(),
                    ),
                  );
                },
                child: const Text('Acessar Painel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventStats(BuildContext context, EventProvider eventProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informações do Evento',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(
                        '${eventProvider.atividades.length}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Atividades',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ],
    );
  }

  Widget _buildUserStats(BuildContext context, UsuarioModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seu Perfil',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          user.nome.isNotEmpty ? user.nome[0].toUpperCase() : '?',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
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
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(user.status).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getStatusLabel(user.status),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: _getStatusColor(user.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.grey[300]),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(context, Icons.person, 'Tipo', _getUserTypeLabel(user.tipo)),
                    _buildStatItem(context, Icons.check_circle, 'Status', _getStatusLabel(user.status)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Color _getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.ativo:
        return Colors.green;
      case UserStatus.pendente:
        return Colors.orange;
      case UserStatus.recusado:
        return Colors.red;
    }
  }

  String _getStatusLabel(UserStatus status) {
    switch (status) {
      case UserStatus.ativo:
        return 'Ativo';
      case UserStatus.pendente:
        return 'Pendente';
      case UserStatus.recusado:
        return 'Recusado';
    }
  }

  String _getUserTypeLabel(UserType tipo) {
    switch (tipo) {
      case UserType.admin:
        return 'Administrador';
      case UserType.palestrante:
        return 'Palestrante';
      case UserType.participante:
        return 'Participante';
    }
  }
}

class ActivityDetailScreen extends StatelessWidget {
  final dynamic atividade;

  const ActivityDetailScreen({Key? key, required this.atividade})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(atividade.titulo)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              atividade.titulo,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Por ${atividade.palestranteNome}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              Icons.location_on,
              atividade.local,
            ),
            _buildInfoRow(
              context,
              Icons.access_time,
              '${atividade.horaInicio.hour}:${atividade.horaInicio.minute.toString().padLeft(2, '0')} - ${atividade.horaFim.hour}:${atividade.horaFim.minute.toString().padLeft(2, '0')}',
            ),
            const SizedBox(height: 16),
            Text(
              'Descrição',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(atividade.descricao),
            const SizedBox(height: 16),
            if (atividade.tags.isNotEmpty) ...[
              Text(
                'Tags',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: atividade.tags
                    .map<Widget>(
                      (tag) => Chip(label: Text(tag)),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
