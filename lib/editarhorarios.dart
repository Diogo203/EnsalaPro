import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HorariosPage extends StatefulWidget {
  const HorariosPage({super.key});

  @override
  State<HorariosPage> createState() => _HorariosPageState();
}

class _HorariosPageState extends State<HorariosPage> {
  final supabase = Supabase.instance.client;
  late Future<List<dynamic>> _horarios;

  Future<List<dynamic>> _carregarHorarios() async {
    final response = await supabase.from('ensalamento').select();
    return response;
  }

  Future<void> _deletarHorario(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja deletar este registro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final confirmarFinal = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmação final'),
          content: const Text('Essa ação é irreversível. Deseja realmente excluir?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Voltar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        ),
      );

      if (confirmarFinal == true) {
        await Supabase.instance.client.from('ensalamento').delete().eq('id', id);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro deletado com sucesso!')),
        );
        setState(() {
          _horarios = _carregarHorarios();
        });
      }
    }
  }


  Future<void> _editarHorario(Map<String, dynamic> dados) async {
    final TextEditingController blocoController =
        TextEditingController(text: dados['bloco']);
    final TextEditingController salaController =
        TextEditingController(text: dados['sala']);
    final TextEditingController primeiroHorarioController =
        TextEditingController(text: dados['primeiro_horario']);
    final TextEditingController segundoHorarioController =
        TextEditingController(text: dados['segundo_horario']);
    final TextEditingController turmaController =
        TextEditingController(text: dados['turma']);
    final TextEditingController turnoController =
        TextEditingController(text: dados['turno']);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Ensalamento'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: blocoController, decoration: const InputDecoration(labelText: 'Bloco')),
              TextField(controller: salaController, decoration: const InputDecoration(labelText: 'Sala')),
              TextField(controller: primeiroHorarioController, decoration: const InputDecoration(labelText: 'Primeiro Horário')),
              TextField(controller: segundoHorarioController, decoration: const InputDecoration(labelText: 'Segundo Horário')),
              TextField(controller: turmaController, decoration: const InputDecoration(labelText: 'Turma')),
              TextField(controller: turnoController, decoration: const InputDecoration(labelText: 'Turno')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await supabase.from('ensalamento').update({
                'bloco': blocoController.text,
                'sala': salaController.text,
                'primeiro_horario': primeiroHorarioController.text,
                'segundo_horario': segundoHorarioController.text,
                'turma': turmaController.text,
                'turno': turnoController.text,
              }).eq('id', dados['id']);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Registro atualizado com sucesso!')),
              );
              setState(() {
                _horarios = _carregarHorarios();
              });
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _horarios = _carregarHorarios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Horários de Ensalamento')),
      body: FutureBuilder<List<dynamic>>(
        future: _horarios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum horário cadastrado.'));
          } else {
            final horarios = snapshot.data!;
            return ListView.builder(
              itemCount: horarios.length,
              itemBuilder: (context, index) {
                final h = horarios[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('Bloco ${h['bloco']} - Sala ${h['sala']}'),
                    subtitle: Text(
                      'Turma: ${h['turma']} - Turno: ${h['turno']}\n'
                      'Horários: ${h['primeiro_horario']} e ${h['segundo_horario']}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _editarHorario(h),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deletarHorario(h['id'] as String),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}