import 'package:flutter/material.dart';

class SecretariaPage extends StatefulWidget {
  const SecretariaPage({super.key});

  @override
  State<SecretariaPage> createState() => _SecretariaPageState();
}

class _SecretariaPageState extends State<SecretariaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página da Secretaria'),
      ),
      body: const Center(
        child: Text('Bem-vindo, secretaria!'),
      ),
    );
  }
}