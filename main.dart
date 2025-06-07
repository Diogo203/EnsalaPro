import 'package:ensala_pro/login.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://plspjoqcxeyajpcoqhkx.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBsc3Bqb3FjeGV5YWpwY29xaGt4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUxNjIxMDEsImV4cCI6MjA2MDczODEwMX0.elSjJVa3WEr_pzCEtrgoVdpuGVb3VIXdixHMt9boJmY', 
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login App',
      home: LoginPage(),
    );
  }
}
