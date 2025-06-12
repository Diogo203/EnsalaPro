// ... suas importações
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ensala_pro/login.dart';

class AlunoPage extends StatefulWidget {
  const AlunoPage({super.key});

  @override
  State<AlunoPage> createState() => _AlunoPageState();
}

class _AlunoPageState extends State<AlunoPage> {
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
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Página do Aluno', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: Builder(
          builder: (context) => IconButton(
            style: IconButton.styleFrom(
              foregroundColor: Colors.white, // Cor do ícone
            ),
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            style: IconButton.styleFrom(
              foregroundColor: Colors.white, // Cor do ícone
            ),
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(color: Colors.blueAccent,
               boxShadow: [
                BoxShadow(
                 color: Colors.grey,
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),	
              child: Text('Menu do Sistema', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Ver Horários'),
              onTap: () => Navigator.pop(context),
            )
          ],
        ),
      ),
      body: Container(
  color: const Color(0xFFabdbe3), // Fundo azul claro
  child: Column(
    children: [
      Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(12),
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
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Pesquisar...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onChanged: (val) => setState(() => pesquisa = val),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: _abrirFiltro,
              icon: const Icon(Icons.filter_list),
              label: const Text('Filtro'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      Expanded(
        child: ListView.builder(
          itemCount: ensalamentosFiltrados.length,
          itemBuilder: (context, index) {
            final e = ensalamentosFiltrados[index];
            final sala = salas.firstWhere((s) => s['id'] == e['sala_id'], orElse: () => {'sala': 'Desconhecida', 'bloco': '-'});
            final curso1 = cursos.firstWhere((c) => c['id'] == e['primeiro_horario'], orElse: () => {'curso': 'Desconhecido', 'periodo': '', 'semestre': ''});
            final curso2 = cursos.firstWhere((c) => c['id'] == e['segundo_horario'], orElse: () => {'curso': 'Desconhecido', 'periodo': '', 'semestre': ''});

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: ListTile(
                title: Text('${e['dia_semana']} - Sala ${sala['sala']} / Bloco ${sala['bloco']}'),
                subtitle: Text(
                  '1º: ${curso1['semestre']} - ${curso1['curso']} (${curso1['periodo']})\n'
                  '2º: ${curso2['semestre']} - ${curso2['curso']} (${curso2['periodo']})',
                ),
              ),
            );
          },
        ),
      ),
    ],
  ),
),

    );
  }
}
