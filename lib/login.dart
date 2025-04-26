import 'package:ensala_pro/principal.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//usuario:email user@user.com
//senha: 12345

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _supabase = Supabase.instance.client;

  Future<void> _login() async {
    try {
      final email = _emailController.text;
      final password = _passwordController.text;

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      final userRow = await _supabase
          .from('usuarios')
          .select('cargo')
          .eq('user_id', user?.id)
          .maybeSingle();

      if (userRow == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário sem cadastro na tabela "usuarios".')),
        );
        return;
      }

      final cargo = (userRow['cargo'] as String).trim().toLowerCase();


      if (!mounted) return;

      if (cargo == 'aluno') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AlunoPage()),
        );
      } else if (cargo == 'professor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfessorPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cargo indefinido para este usuário.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.toString()}')),
      );
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        // 🔹 Imagem de fundo
        Positioned.fill(
          child: Image.asset(
            'assets/background_login.png',
            fit: BoxFit.cover,
          ),
        ),

        // 🔹 Conteúdo principal
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(34),
            child: Container(
              padding: const EdgeInsets.all(64),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'EnsalaPro',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Entrar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Esqueci minha senha'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}


