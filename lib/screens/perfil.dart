import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authService = Provider.of<AuthService>(context);
    final user = userProvider.currentUser;
    final isDark = themeProvider.isDarkMode;

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.signOut(),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: user.fotoUrl.isNotEmpty 
                    ? NetworkImage(user.fotoUrl) 
                    : null,
                  child: user.fotoUrl.isEmpty ? const Icon(Icons.person, size: 60) : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    radius: 18,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      onPressed: () => _editField(context, 'URL da Foto', user.fotoUrl, (val) => userProvider.updateProfile(fotoUrl: val)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          _buildSectionTitle('Dados da Conta', isDark),
          _buildInfoTile(Icons.person, 'Nome', user.nome, () => _editField(context, 'Nome', user.nome, (val) => userProvider.updateProfile(nome: val))),
          _buildInfoTile(Icons.email, 'Email', user.email, null),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Informações Pessoais', isDark),
          _buildInfoTile(Icons.cake, 'Data de Nascimento', user.dataNascimento.isEmpty ? 'Não informada' : user.dataNascimento, 
            () => _editField(context, 'Data de Nascimento', user.dataNascimento, (val) => userProvider.updateProfile(dataNascimento: val))),
          _buildInfoTile(Icons.phone, 'Telefone', user.telefone.isEmpty ? 'Não informado' : user.telefone, 
            () => _editField(context, 'Telefone', user.telefone, (val) => userProvider.updateProfile(telefone: val))),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Estudos', isDark),
          _buildInfoTile(Icons.flag, 'Foco do Estudo', user.focoEstudo.isEmpty ? 'Não definido' : user.focoEstudo, 
            () => _editField(context, 'Foco do Estudo', user.focoEstudo, (val) => userProvider.updateProfile(focoEstudo: val))),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Preferências', isDark),
          SwitchListTile(
            title: const Text('Modo Escuro'),
            secondary: const Icon(Icons.dark_mode, color: Colors.blueAccent),
            value: isDark,
            onChanged: (val) => themeProvider.toggleTheme(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/inicio');
          if (index == 1) Navigator.pushReplacementNamed(context, '/metricas');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.history_edu), label: 'Estudo'),
          BottomNavigationBarItem(icon: Icon(Icons.insert_chart), label: 'Métricas'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.blueAccent : Colors.blue[900],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value, VoidCallback? onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(value),
      subtitle: Text(label),
      trailing: onTap != null ? const Icon(Icons.edit, size: 20) : null,
      onTap: onTap,
    );
  }

  void _editField(BuildContext context, String title, String initialValue, Function(String) onSave) {
    final controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Digite o novo $title'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
