import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';
import 'providers/timer_provider.dart';
import 'services/auth_service.dart';
import 'screens/registrar_estudo.dart';
import 'screens/metricas.dart';
import 'screens/perfil.dart';

// Nota: Você precisará adicionar o arquivo firebase_options.dart gerado pelo FlutterFire CLI
// import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicialização do Firebase (Comentada até você configurar seu projeto)
  /*
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  */

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
      ],
      child: const ReviseiApp(),
    ),
  );
}

class ReviseiApp extends StatelessWidget {
  const ReviseiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'Revisei',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,
      home: const AuthWrapper(),
      routes: {
        '/inicio': (context) => const RegistrarEstudoScreen(),
        '/metricas': (context) => const MetricasScreen(),
        '/perfil': (context) => const PerfilScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    // Se não estiver logado, tenta login anônimo para uso pessoal
    if (!authService.isAuthenticated) {
      authService.signInAnonymously();
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    return const RegistrarEstudoScreen();
  }
}
