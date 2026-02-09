import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nomeController;
  late TextEditingController _matriculaController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _matriculaController = TextEditingController();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _matriculaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.currentUser;

        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        _nomeController.text = user.nome;
        _matriculaController.text = user.matricula ?? '';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Meu Perfil'),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(user),
                const SizedBox(height: 24),
                _buildUserInfo(user),
                const SizedBox(height: 24),
                _buildEditForm(),
                const SizedBox(height: 24),
                _buildLogoutButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(UsuarioModel user) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              user.nome.isNotEmpty ? user.nome[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.nome,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Chip(
            label: Text(_getTipoUsuarioLabel(user.tipo)),
            backgroundColor: _getTipoUsuarioCor(user.tipo),
            labelStyle: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(UsuarioModel user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Email', user.email),
            const Divider(),
            _buildInfoRow('Instituição', user.instituicao ?? 'Não informado'),
            const Divider(),
            _buildInfoRow(
              'Status',
              _getStatusLabel(user.status),
            ),
            if (user.bio != null) ...[
              const Divider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bio',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(user.bio!),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Editar Perfil',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _nomeController,
          decoration: InputDecoration(
            labelText: 'Nome',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _matriculaController,
          decoration: InputDecoration(
            labelText: 'Matrícula',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: userProvider.isLoading
                    ? null
                    : () => _updateProfile(context, userProvider),
                child: userProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Salvar Alterações'),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _updateProfile(
    BuildContext context,
    UserProvider userProvider,
  ) async {
    await userProvider.updateProfile(
      nome: _nomeController.text,
      fotoPerfil: null,
      instituicao: 'Universidade Federal de Ouro Preto – UFOP',
      matricula: _matriculaController.text.isEmpty ? null : _matriculaController.text,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso')),
      );
    }
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _logout(context),
        icon: const Icon(Icons.logout),
        label: const Text('Sair'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final userProvider = context.read<UserProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja sair da aplicação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await userProvider.signOut();
              if (mounted) {
                Navigator.pop(context);
                Navigator.of(context).pushReplacementNamed('/signin');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  String _getTipoUsuarioLabel(UserType tipo) {
    switch (tipo) {
      case UserType.participante:
        return 'Participante';
      case UserType.palestrante:
        return 'Palestrante';
      case UserType.admin:
        return 'Administrador';
    }
  }

  Color _getTipoUsuarioCor(UserType tipo) {
    switch (tipo) {
      case UserType.participante:
        return Colors.blue;
      case UserType.palestrante:
        return Colors.orange;
      case UserType.admin:
        return Colors.red;
    }
  }

  String _getStatusLabel(UserStatus status) {
    switch (status) {
      case UserStatus.ativo:
        return 'Ativo';
      case UserStatus.pendente:
        return 'Pendente de Aprovação';
      case UserStatus.recusado:
        return 'Recusado';
    }
  }
}