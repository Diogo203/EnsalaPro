import 'package:flutter/material.dart';


class AlunoPage extends StatelessWidget {
  const AlunoPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Página do Aluno')),
      body: const Center(child: Text('Bem-vindo, aluno!')),
    );
  }
}

class ProfessorPage extends StatelessWidget {
  const ProfessorPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Página do Professor')),
      body: const Center(child: Text('Bem-vindo, professor!')),
    );
  }
}
