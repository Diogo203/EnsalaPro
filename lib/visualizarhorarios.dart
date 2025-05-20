import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VisualizarHorariosPage extends StatefulWidget {
  const VisualizarHorariosPage({super.key});

  @override
  State<VisualizarHorariosPage> createState() => _VisualizarHorariosPageState();
}

class _VisualizarHorariosPageState extends State<VisualizarHorariosPage> {
  late Future<List<Map<String, dynamic>>> _horarios;

  @override
  void initState() {
    super.initState();
    _horarios = _carregarHorarios();
  }

  Future<List<Map<String, dynamic>>> _carregarHorarios() async {
    final response = await Supabase.instance.client
        .from('ensalamento')
        .select()
        .order('bloco', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Horários de Ensalamento')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _horarios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum horário cadastrado.'));
          }

          final horarios = snapshot.data!;

          return ListView.builder(
            itemCount: horarios.length,
            itemBuilder: (context, index) {
              final h = horarios[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text('Sala ${h['sala']} - Bloco ${h['bloco']}'),
                  subtitle: Text(
                    'Horários: ${h['primeiro_horario']} e ${h['segundo_horario']}\n'
                    'Turma: ${h['turma']} - Turno: ${h['turno']}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
