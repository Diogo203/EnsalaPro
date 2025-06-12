import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ensala_pro/login.dart';

class ProfessorPage extends StatefulWidget {
  const ProfessorPage({super.key});

  @override
  State<ProfessorPage> createState() => _ProfessorPageState();
}

class _ProfessorPageState extends State<ProfessorPage> {
  final supabase = Supabase.instance.client;

  List<dynamic> ensalamentos = [];
  List<dynamic> cursos = [];
  List<dynamic> salas = [];

  String pesquisa = '';
  String? filtroCurso;
  String? filtroPeriodo;
  String? filtroBloco;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final ensRes = await supabase.from('ensalamento').select();
    final cursosRes = await supabase.from('curso').select();
    final salasRes = await supabase.from('sala').select();

    setState(() {
      ensalamentos = ensRes;
      cursos = cursosRes;
      salas = salasRes;
    });
  }

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
      await Supabase.instance.client.auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout realizado com sucesso!')),
      );
    }
  }

  List<dynamic> get ensalamentosFiltrados {
    return ensalamentos.where((e) {
      final curso1 = cursos.firstWhere((c) => c['id'] == e['primeiro_horario'], orElse: () => null);
      final curso2 = cursos.firstWhere((c) => c['id'] == e['segundo_horario'], orElse: () => null);
      final sala = salas.firstWhere((s) => s['id'] == e['sala_id'], orElse: () => null);

      if (curso1 == null || curso2 == null || sala == null) return false;

      final combinado = '${curso1['curso']} ${curso1['periodo']} ${curso1['semestre']} '
          '${curso2['curso']} ${curso2['periodo']} ${curso2['semestre']} '
          'sala ${sala['sala']} bloco ${sala['bloco']} ${e['dia_semana']}'.toLowerCase();

      if (pesquisa.isNotEmpty && !combinado.contains(pesquisa.toLowerCase())) {
        return false;
      }

      if (filtroCurso != null && filtroCurso!.isNotEmpty) {
        if (curso1['curso'] != filtroCurso && curso2['curso'] != filtroCurso) return false;
      }

      if (filtroPeriodo != null && filtroPeriodo!.isNotEmpty) {
        if (curso1['periodo'] != filtroPeriodo && curso2['periodo'] != filtroPeriodo) return false;
      }

      if (filtroBloco != null && filtroBloco!.isNotEmpty) {
        if (sala['bloco'] != filtroBloco) return false;
      }

      return true;
    }).toList();
  }

  void _abrirFiltro() {
    showDialog(
      context: context,
      builder: (context) {
        String? cursoSelecionado = filtroCurso;
        String? periodoSelecionado = filtroPeriodo;
        String? blocoSelecionado = filtroBloco;

        final cursosUnicos = cursos.map((c) => c['curso'] as String).toSet().toList();
        final periodosUnicos = cursos.map((c) => c['periodo'] as String).toSet().toList();
        final blocosUnicos = salas.map((s) => s['bloco'] as String).toSet().toList();

        return AlertDialog(
          title: const Text('Filtrar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: cursoSelecionado,
                hint: const Text('Curso'),
                isExpanded: true,
                items: cursosUnicos.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => cursoSelecionado = val,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: periodoSelecionado,
                hint: const Text('Período'),
                isExpanded: true,
                items: periodosUnicos.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (val) => periodoSelecionado = val,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: blocoSelecionado,
                hint: const Text('Bloco'),
                isExpanded: true,
                items: blocosUnicos.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                onChanged: (val) => blocoSelecionado = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  filtroCurso = null;
                  filtroPeriodo = null;
                  filtroBloco = null;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Limpar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  filtroCurso = cursoSelecionado;
                  filtroPeriodo = periodoSelecionado;
                  filtroBloco = blocoSelecionado;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Aplicar'),
            ),
          ],
        );
      },
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFabdbe3),
    appBar: AppBar(
      backgroundColor: Colors.blueAccent,
      title: const Text(
        'Página do Professor',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          tooltip: 'Deslogar',
          onPressed: () => _logout(context),
        ),
      ],
    ),
    drawer: Drawer(
      elevation: 8,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),
            child: Text(
              'Menu do Professor',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Ver Horários'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.room),
            title: const Text('Salas Disponíveis'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Perfil'),
            onTap: () {},
          ),
        ],
      ),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Pesquisar...',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                    onChanged: (val) => setState(() => pesquisa = val),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _abrirFiltro,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: ensalamentosFiltrados.length,
            itemBuilder: (context, index) {
              final e = ensalamentosFiltrados[index];
              final sala = salas.firstWhere((s) => s['id'] == e['sala_id'], orElse: () => {'sala': 'Desconhecida', 'bloco': '-'});
              final curso1 = cursos.firstWhere((c) => c['id'] == e['primeiro_horario'], orElse: () => {'curso': 'Desconhecido', 'periodo': '', 'semestre': ''});
              final curso2 = cursos.firstWhere((c) => c['id'] == e['segundo_horario'], orElse: () => {'curso': 'Desconhecido', 'periodo': '', 'semestre': ''});

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${e['dia_semana']} - Sala ${sala['sala']} / Bloco ${sala['bloco']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '1º: ${curso1['semestre']} - ${curso1['curso']} (${curso1['periodo']})\n'
                        '2º: ${curso2['semestre']} - ${curso2['curso']} (${curso2['periodo']})',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}
