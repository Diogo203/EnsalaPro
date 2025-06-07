import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ensala_pro/login.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      context: _scaffoldKey.currentContext!,
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
      context: _scaffoldKey.currentContext!,
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
                  _abrirListagemUsuariosModal(_scaffoldKey.currentContext!);
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
    context: _scaffoldKey.currentContext!,
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
                  
                  await supabase.from('usuarios').insert({
                    'user_id': user.id,
                    'nome': nomeController.text.trim(),
                    'cargo': cargo,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Usuário cadastrado com sucesso')),
                  );

                  
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
  // Loading inicial
  showDialog(
    context: _scaffoldKey.currentContext!,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    // Buscar dados da view usuario_com_email
    final List usuariosOriginais = await supabase
        .from('usuario_com_email')
        .select('id, nome, cargo, user_id, email');

    Navigator.pop(context); // Fecha o loading

    if (usuariosOriginais.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum usuário encontrado.')),
      );
      return;
    }

    // Controllers para edição
    Map<String, Map<String, TextEditingController>> controllers = {};
    for (var u in usuariosOriginais) {
      final id = u['id'].toString();
      controllers[id] = {
        'nome': TextEditingController(text: u['nome'] ?? ''),
        'cargo': TextEditingController(text: u['cargo'] ?? ''),
      };
    }

    List usuariosFiltrados = List.from(usuariosOriginais);
    String filtroCargo = 'Todos';
    String pesquisaNome = '';

    showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void aplicarFiltro() {
              setState(() {
                usuariosFiltrados = usuariosOriginais.where((usuario) {
                  final nome = (usuario['nome'] ?? '').toString().toLowerCase();
                  final cargo = (usuario['cargo'] ?? '').toString();

                  final correspondeNome = nome.contains(pesquisaNome.toLowerCase());
                  final correspondeCargo = filtroCargo == 'Todos' || cargo == filtroCargo;

                  return correspondeNome && correspondeCargo;
                }).toList();
              });
            }

            return AlertDialog(
              title: const Text('Listar Usuários'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  children: [
                    // 🔎 Filtros
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Pesquisar por nome',
                              prefixIcon: Icon(Icons.search),
                            ),
                            onChanged: (value) {
                              pesquisaNome = value;
                              aplicarFiltro();
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        DropdownButton<String>(
                          value: filtroCargo,
                          items: <String>[
                            'Todos',
                            ...{
                              ...usuariosOriginais
                                  .map((e) => e['cargo'] ?? 'Sem cargo')
                            }
                          ].map((cargo) {
                            return DropdownMenuItem(
                              value: cargo,
                              child: Text(cargo),
                            );
                          }).toList(),
                          onChanged: (value) {
                            filtroCargo = value!;
                            aplicarFiltro();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // 🗒 Lista
                    Expanded(
                      child: usuariosFiltrados.isEmpty
                          ? const Center(child: Text('Nenhum usuário encontrado.'))
                          : ListView.builder(
                              itemCount: usuariosFiltrados.length,
                              itemBuilder: (context, index) {
                                final usuario = usuariosFiltrados[index];
                                final id = usuario['id'].toString();

                                final nomeController = controllers[id]!['nome']!;
                                final cargoController = controllers[id]!['cargo']!;

                                return Card(
                                  elevation: 3,
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: nomeController,
                                                decoration: const InputDecoration(
                                                  labelText: 'Nome',
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: TextField(
                                                controller: cargoController,
                                                decoration: const InputDecoration(
                                                  labelText: 'Cargo',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Email: ${usuario['email'] ?? 'Não encontrado'}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.save,
                                                  color: Colors.blue),
                                              onPressed: () async {
                                                await supabase
                                                    .from('usuarios')
                                                    .update({
                                                      'nome': nomeController.text,
                                                      'cargo': cargoController.text,
                                                    })
                                                    .eq('id', id);

                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          'Usuário atualizado')),
                                                );

                                                setState(() {
                                                  usuario['nome'] =
                                                      nomeController.text;
                                                  usuario['cargo'] =
                                                      cargoController.text;
                                                });
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () async {
                                                await supabase
                                                    .from('usuarios')
                                                    .delete()
                                                    .eq('id', id);

                                                setState(() {
                                                  usuariosOriginais.removeWhere(
                                                      (u) => u['id'] == id);
                                                  usuariosFiltrados
                                                      .removeAt(index);
                                                  controllers.remove(id);
                                                });

                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content:
                                                          Text('Usuário deletado')),
                                                );
                                              },
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
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
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Página da Secretaria'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Deslogar',
            hoverColor:const Color.fromARGB(255, 220, 28, 28),
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
