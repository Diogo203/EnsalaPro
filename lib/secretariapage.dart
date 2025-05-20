import 'package:flutter/material.dart';
import 'package:ensala_pro/login.dart';
import 'package:ensala_pro/crudensalamento.dart';
import 'package:ensala_pro/editarhorarios.dart';


class SecretariaPage extends StatefulWidget {
  const SecretariaPage({super.key});

  @override
  State<SecretariaPage> createState() => _SecretariaPageState();
}

class _SecretariaPageState extends State<SecretariaPage> {
  // Função de deslogar
  void _logout(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar logout'),
        content: const Text('Você tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout realizado com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página da Secretaria'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Deslogar',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu da Secretaria',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Ver Horários'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HorariosPage()),
                );
                // Ir para tela de horários
              },
            ),
            ListTile(
              leading: const Icon(Icons.manage_accounts),
              title: const Text('Gerenciar Ensalamento'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FormularioEnsalamentoPage()),
                );
                // Ir para tela de gerenciamento de salas
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurações'),
              onTap: () {
                // Ir para tela de configurações
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          'Bem-vindo à área da secretaria!\nUse o menu para acessar as funcionalidades.',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
