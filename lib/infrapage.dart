import 'package:flutter/material.dart';

class Infrapage extends StatelessWidget {
  const Infrapage ({super.key});
  @override
  Widget build(BuildContext content) {
    return Scaffold(
      appBar: AppBar(title: const Text('Página da Infraestrutura'),),
      body: const Center(child: Text('Bem-vindo, Infraaestrutura!'),),
    );
  }
}