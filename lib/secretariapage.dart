import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ensala_pro/login.dart';

class SecretariaPage extends StatefulWidget {
  const SecretariaPage({super.key});

  @override
  State<SecretariaPage> createState() => _SecretariaPageState();
}

class _SecretariaPageState extends State<SecretariaPage> {
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
      await supabase.auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout realizado com sucesso!')),
      );
    }
  }

  void _abrirFormularioSalaModal(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _blocoController = TextEditingController();
    final TextEditingController _salaController = TextEditingController();
    final TextEditingController _cadeirasController = TextEditingController();

    bool tv = false;
    bool projetor = false;
    bool arCondicionado = false;
    bool caixaSom = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Adicionar Sala'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _blocoController,
                        decoration: const InputDecoration(labelText: 'Bloco'),
                        validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                      ),
                      TextFormField(
                        controller: _salaController,
                        decoration: const InputDecoration(labelText: 'Sala'),
                        validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                      ),
                      TextFormField(
                        controller: _cadeirasController,
                        decoration: const InputDecoration(labelText: 'Número de Cadeiras'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                      ),
                      const SizedBox(height: 10),
                      CheckboxListTile(
                        title: const Text("TV"),
                        value: tv,
                        onChanged: (val) => setState(() => tv = val!),
                      ),
                      CheckboxListTile(
                        title: const Text("Projetor"),
                        value: projetor,
                        onChanged: (val) => setState(() => projetor = val!),
                      ),
                      CheckboxListTile(
                        title: const Text("Ar Condicionado"),
                        value: arCondicionado,
                        onChanged: (val) => setState(() => arCondicionado = val!),
                      ),
                      CheckboxListTile(
                        title: const Text("Caixa de Som"),
                        value: caixaSom,
                        onChanged: (val) => setState(() => caixaSom = val!),
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
                      final data = {
                        'bloco': _blocoController.text,
                        'sala': _salaController.text,
                        'numero_cadeiras': int.tryParse(_cadeirasController.text) ?? 0,
                        'tv': tv,
                        'projetor': projetor,
                        'ar_condicionado': arCondicionado,
                        'caixa_som': caixaSom,
                      };

                      await supabase.from('ensalamento').insert(data);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sala cadastrada com sucesso!')),
                      );

                      Navigator.of(context).pop();
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

  void _abrirModalUsuarios(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuários'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMenuCard(
                icon: Icons.person_add,
                label: 'Cadastro de Usuários',
                onTap: () {
                  Navigator.of(context).pop();
                  _abrirCadastroUsuarioModal(context);
                },
              ),
              _buildMenuCard(
                icon: Icons.people,
                label: 'Listar Usuários',
                onTap: () {
                  Navigator.of(context).pop();
                  _abrirListagemUsuariosModal(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _abrirCadastroUsuarioModal(BuildContext context) {
  final _formKey = GlobalKey<FormState>();
  String cargo = 'aluno';
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Cadastro de Usuário'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) => v!.isEmpty ? 'Por favor, insira um nome' : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v != null && v.contains('@')
                    ? null
                    : 'Email inválido',
              ),
              TextFormField(
                controller: senhaController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha'),
                validator: (v) => v != null && v.length >= 6
                    ? null
                    : 'A senha deve ter no mínimo 6 caracteres',
              ),
              DropdownButtonFormField<String>(
                value: cargo,
                items: ['aluno', 'professor', 'infraestrutura', 'secretaria']
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e[0].toUpperCase() + e.substring(1)),
                        ))
                    .toList(),
                onChanged: (val) => cargo = val!,
                decoration: const InputDecoration(labelText: 'Cargo'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              try {
                final response = await supabase.auth.signUp(
                  email: emailController.text.trim(),
                  password: senhaController.text.trim(),
                );

                final user = response.user;

                if (user != null) {
                  // Insere na tabela 'usuarios' com user_id do supabase
                  await supabase.from('usuarios').insert({
                    'user_id': user.id,
                    'nome': nomeController.text.trim(),
                    'cargo': cargo,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Usuário cadastrado com sucesso')),
                  );

                  // Opcional: desloga o usuário criado para manter a sessão atual
                  await supabase.auth.signOut();

                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erro ao criar usuário')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro: $e')),
                );
              }
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    ),
  );
}


void _abrirListagemUsuariosModal(BuildContext context) async {
  // Mostra loading enquanto busca os dados
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final List usuarios =
        await supabase.from('usuarios').select();

    // Fecha o dialog de loading
    Navigator.pop(context);

    if (usuarios.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum usuário encontrado.')),
      );
      return;
    }

    final Map<String, TextEditingController> nomeControllers = {
      for (var u in usuarios)
        u['id']: TextEditingController(text: u['nome'] ?? '')
    };

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Listar Usuários'),
              content: SizedBox(
                width: 300,
                height: 400,
                child: ListView.builder(
                  itemCount: usuarios.length,
                  itemBuilder: (context, index) {
                    final usuario = usuarios[index];
                    final String id = usuario['id'];
                    final nomeController = nomeControllers[id]!;

                    final String cargo =
                        (usuario['cargo'] ?? 'Sem cargo').toString();

                    return Card(
                      elevation: 2,
                      margin:
                          const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                      child: ListTile(
                        title: TextField(
                          controller: nomeController,
                          decoration: const InputDecoration(
                            hintText: 'Nome',
                            border: InputBorder.none,
                          ),
                        ),
                        subtitle: Text('Cargo: $cargo'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.save, color: Colors.blue),
                              onPressed: () async {
                                await supabase
                                    .from('usuarios')
                                    .update({
                                      'nome': nomeController.text,
                                    })
                                    .eq('id', id);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Usuário atualizado')),
                                );

                                setState(() {
                                  usuario['nome'] = nomeController.text;
                                });
                              },
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await supabase
                                    .from('usuarios')
                                    .delete()
                                    .eq('id', id);

                                setState(() {
                                  usuarios.removeAt(index);
                                  nomeControllers.remove(id);
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Usuário deletado')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fechar'),
                ),
              ],
            );
          },
        );
      },
    );
  } catch (e) {
    Navigator.pop(context); // Fecha o loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao carregar usuários: $e')),
    );
  }
}
void abrirListagemUsuariosModal(BuildContext context) async {
  // Mostra loading enquanto busca os dados
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final List usuarios =
        await supabase.from('usuarios').select();

    // Fecha o dialog de loading
    Navigator.pop(context);

    if (usuarios.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum usuário encontrado.')),
      );
      return;
    }

    final Map<String, TextEditingController> nomeControllers = {
      for (var u in usuarios)
        u['id']: TextEditingController(text: u['nome'] ?? '')
    };

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Listar Usuários'),
              content: SizedBox(
                width: 300,
                height: 400,
                child: ListView.builder(
                  itemCount: usuarios.length,
                  itemBuilder: (context, index) {
                    final usuario = usuarios[index];
                    final String id = usuario['id'];
                    final nomeController = nomeControllers[id]!;

                    final String cargo =
                        (usuario['cargo'] ?? 'Sem cargo').toString();

                    return Card(
                      elevation: 2,
                      margin:
                          const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                      child: ListTile(
                        title: TextField(
                          controller: nomeController,
                          decoration: const InputDecoration(
                            hintText: 'Nome',
                            border: InputBorder.none,
                          ),
                        ),
                        subtitle: Text('Cargo: $cargo'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.save, color: Colors.blue),
                              onPressed: () async {
                                await supabase
                                    .from('usuarios')
                                    .update({
                                      'nome': nomeController.text,
                                    })
                                    .eq('id', id);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Usuário atualizado')),
                                );

                                setState(() {
                                  usuario['nome'] = nomeController.text;
                                });
                              },
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await supabase
                                    .from('usuarios')
                                    .delete()
                                    .eq('id', id);

                                setState(() {
                                  usuarios.removeAt(index);
                                  nomeControllers.remove(id);
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Usuário deletado')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fechar'),
                ),
              ],
            );
          },
        );
      },
    );
  } catch (e) {
    Navigator.pop(context); // Fecha o loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao carregar usuários: $e')),
    );
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página da Secretaria'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Deslogar',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          children: [
            _buildMenuCard(
              icon: Icons.class_,
              label: 'CRUD Sala',
              onTap: () => _abrirFormularioSalaModal(context),
            ),
            _buildMenuCard(
              icon: Icons.person,
              label: 'Usuários',
              onTap: () => _abrirModalUsuarios(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.blue),
              const SizedBox(height: 6),
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
}
