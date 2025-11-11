import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:desarrollo_jmas/app/screens/home/home_page.dart';
import 'package:desarrollo_jmas/app/screens/home/login2.dart';
import 'package:desarrollo_jmas/app/configs/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Ventana
  doWhenWindowReady(() {
    const initialSize = Size(1300, 800);
    //const initialSize2 = Size(width, height);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });

  //Verificar autenticación antes de iniciar la app
  final authService = AuthService();
  final isLoggedIn = await authService.isLoggedIn();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'), // Español como idioma principal
        Locale('en', 'US'), // Inglés como respaldo
      ],
      debugShowCheckedModeBanner: false,
      title: 'App Almacén JMAS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: isLoggedIn ? const HomePage() : const LoginWidget(),
      routes: {
        '/login': (context) => const LoginWidget(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
