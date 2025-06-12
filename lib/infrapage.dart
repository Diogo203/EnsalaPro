import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ensala_pro/login.dart';

class Infrapage extends StatefulWidget {
  const Infrapage({super.key});

  @override
  State<Infrapage> createState() => _InfrapageState();
}

class _InfrapageState extends State<Infrapage> {
  final supabase = Supabase.instance.client;

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
    }
  }

  Future<void> _abrirModalManutencao() async {
    final salas = await supabase.from('sala').select();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Manutenção de Salas'),
          content: SizedBox(
            width: double.maxFinite,
            child: salas.isEmpty
                ? const Text("Nenhuma sala encontrada.")
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: salas.length,
                    itemBuilder: (context, index) {
                      final sala = salas[index];
                      return ListTile(
                        title: Text('Sala: ${sala['sala']} - Bloco: ${sala['bloco']}'),
                        subtitle: Text('Cadeiras: ${sala['numero_cadeiras']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.of(context).pop();
                                _abrirEditarSalaModal(sala);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _excluirSala(sala['id']),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void _abrirEditarSalaModal(dynamic sala) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController blocoController = TextEditingController(text: sala['bloco']);
    final TextEditingController salaController = TextEditingController(text: sala['sala']);
    final TextEditingController cadeirasController = TextEditingController(text: sala['numero_cadeiras'].toString());

    bool tv = sala['tv'] ?? false;
    bool projetor = sala['projetor'] ?? false;
    bool arCondicionado = sala['ar_condicionado'] ?? false;
    bool caixaSom = sala['caixa_som'] ?? false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(  // para setState interno funcionar
          builder: (context, setStateModal) {
            return AlertDialog(
              title: const Text('Editar Sala'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: blocoController,
                        decoration: const InputDecoration(labelText: 'Bloco'),
                        validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                      ),
                      TextFormField(
                        controller: salaController,
                        decoration: const InputDecoration(labelText: 'Sala'),
                        validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                      ),
                      TextFormField(
                        controller: cadeirasController,
                        decoration: const InputDecoration(labelText: 'Número de Cadeiras'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                      ),
                      CheckboxListTile(
                        value: tv,
                        onChanged: (value) => setStateModal(() => tv = value ?? false),
                        title: const Text('TV'),
                      ),
                      CheckboxListTile(
                        value: projetor,
                        onChanged: (value) => setStateModal(() => projetor = value ?? false),
                        title: const Text('Projetor'),
                      ),
                      CheckboxListTile(
                        value: arCondicionado,
                        onChanged: (value) => setStateModal(() => arCondicionado = value ?? false),
                        title: const Text('Ar Condicionado'),
                      ),
                      CheckboxListTile(
                        value: caixaSom,
                        onChanged: (value) => setStateModal(() => caixaSom = value ?? false),
                        title: const Text('Caixa de Som'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await supabase.from('sala').update({
                        'bloco': blocoController.text,
                        'sala': salaController.text,
                        'numero_cadeiras': int.parse(cadeirasController.text),
                        'tv': tv,
                        'projetor': projetor,
                        'ar_condicionado': arCondicionado,
                        'caixa_som': caixaSom,
                      }).eq('id', sala['id']);

                      Navigator.of(context).pop();
                      _abrirModalManutencao();
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _excluirSala(String id) async {
    await supabase.from('sala').delete().eq('id', id);
    _abrirModalManutencao();
  }

  // Novo modal para cadastro
  void _abrirCadastroSalaModal() {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController blocoController = TextEditingController();
    final TextEditingController salaController = TextEditingController();
    final TextEditingController cadeirasController = TextEditingController();

    bool tv = false;
    bool projetor = false;
    bool arCondicionado = false;
    bool caixaSom = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              title: const Text('Cadastro de Sala'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: blocoController,
                        decoration: const InputDecoration(labelText: 'Bloco'),
                        validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                      ),
                      TextFormField(
                        controller: salaController,
                        decoration: const InputDecoration(labelText: 'Sala'),
                        validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                      ),
                      TextFormField(
                        controller: cadeirasController,
                        decoration: const InputDecoration(labelText: 'Número de Cadeiras'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                      ),
                      CheckboxListTile(
                        value: tv,
                        onChanged: (value) => setStateModal(() => tv = value ?? false),
                        title: const Text('TV'),
                      ),
                      CheckboxListTile(
                        value: projetor,
                        onChanged: (value) => setStateModal(() => projetor = value ?? false),
                        title: const Text('Projetor'),
                      ),
                      CheckboxListTile(
                        value: arCondicionado,
                        onChanged: (value) => setStateModal(() => arCondicionado = value ?? false),
                        title: const Text('Ar Condicionado'),
                      ),
                      CheckboxListTile(
                        value: caixaSom,
                        onChanged: (value) => setStateModal(() => caixaSom = value ?? false),
                        title: const Text('Caixa de Som'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await supabase.from('sala').insert({
                        'bloco': blocoController.text,
                        'sala': salaController.text,
                        'numero_cadeiras': int.parse(cadeirasController.text),
                        'tv': tv,
                        'projetor': projetor,
                        'ar_condicionado': arCondicionado,
                        'caixa_som': caixaSom,
                      });

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sala cadastrada com sucesso!')),
                      );
                    }
                  },
                  child: const Text('Cadastrar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

 Widget _buildMenuCard({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    splashColor: Colors.blue.shade100,
    child: Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: Colors.blueAccent),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    ),
  );
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.blueAccent,
      title: const Text(
        'Página da Infraestrutura',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          style: IconButton.styleFrom(foregroundColor: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Deslogar',
          style: IconButton.styleFrom(foregroundColor: Colors.white),
          onPressed: () => _logout(context),
        ),
      ],
    ),
    drawer: Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: const [
          DrawerHeader(
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              'Menu da Infraestrutura',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.build),
            title: Text('Solicitações de Manutenção'),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Configurações'),
          ),
        ],
      ),
    ),
    body: Container(
      color: const Color(0xFFabdbe3),
      padding: const EdgeInsets.all(12),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.2,
        children: [
          _buildMenuCard(
            icon: Icons.build,
            label: 'Manutenção',
            onTap: _abrirModalManutencao,
          ),
          _buildMenuCard(
            icon: Icons.meeting_room,
            label: 'Cadastro de Salas',
            onTap: _abrirCadastroSalaModal,
          ),
          _buildMenuCard(
            icon: Icons.settings,
            label: 'Configurações',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configurações ainda não implementadas.')),
              );
            },
          ),
          _buildMenuCard(
            icon: Icons.info,
            label: 'Sobre o Sistema',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Sistema de Infraestrutura',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 Ensala Pro',
              );
            },
          ),
        ],
      ),
    ),
  );
}
}