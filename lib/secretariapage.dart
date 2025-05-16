import 'package:flutter/material.dart';

class SecretariaPage extends StatelessWidget {
  const SecretariaPage ({super.key});
  @override
  Widget build(BuildContext content) {
    return Scaffold(
      appBar: AppBar(title: const Text('Página da Secretaria'),),
      body: const Center(child: Text('Bem-vindo, secretaria!'),),
    );
  }
}