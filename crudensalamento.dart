import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FormularioEnsalamentoPage extends StatefulWidget {
  const FormularioEnsalamentoPage({super.key});

  @override
  State<FormularioEnsalamentoPage> createState() => _FormularioEnsalamentoPageState();
}

class _FormularioEnsalamentoPageState extends State<FormularioEnsalamentoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _blocoController = TextEditingController();
  final TextEditingController _salaController = TextEditingController();
  final TextEditingController _primeiroHorarioController = TextEditingController();
  final TextEditingController _segundoHorarioController = TextEditingController();
  final TextEditingController _turmaController = TextEditingController();
  final TextEditingController _turnoController = TextEditingController();

  Future<void> _salvarEnsalamento() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'bloco': _blocoController.text,
        'sala': _salaController.text,
        'primeiro_horario': _primeiroHorarioController.text,
        'segundo_horario': _segundoHorarioController.text,
        'turma': _turmaController.text,
        'turno': _turnoController.text,
      };

      await Supabase.instance.client.from('ensalamento').insert(data);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro adicionado com sucesso!')),
      );

      _formKey.currentState?.reset();
      _blocoController.clear();
      _salaController.clear();
      _primeiroHorarioController.clear();
      _segundoHorarioController.clear();
      _turmaController.clear();
      _turnoController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formulário de Ensalamento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _blocoController, decoration: const InputDecoration(labelText: 'Bloco'), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              TextFormField(controller: _salaController, decoration: const InputDecoration(labelText: 'Sala'), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              TextFormField(controller: _primeiroHorarioController, decoration: const InputDecoration(labelText: 'Primeiro Horário'), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              TextFormField(controller: _segundoHorarioController, decoration: const InputDecoration(labelText: 'Segundo Horário'), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              TextFormField(controller: _turmaController, decoration: const InputDecoration(labelText: 'Turma'), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              TextFormField(controller: _turnoController, decoration: const InputDecoration(labelText: 'Turno'), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvarEnsalamento,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
