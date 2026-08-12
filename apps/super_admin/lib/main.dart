import 'dart:io';

import 'package:flutter/material.dart';
import 'package:icue_face_sdk/icue_face_sdk.dart';
import 'package:provider/provider.dart';

import 'core/di/injection.dart';
import 'core/storage/pref_service.dart';
import 'providers/auth_provider.dart';
import 'providers/embedding_provider.dart';
import 'providers/student_provider.dart';
import 'providers/identify_provider.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/student_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Resolve pre-resolved dependencies (like SharedPreferences) & dependencies tree
  await configureDependencies();

  if (Platform.isAndroid) {
    try {
      await getIt<IcueFaceSdk>().initialize();
    } catch (e) {
      debugPrint('Error initializing IcueFaceSdk: $e');
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<StudentProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<EmbeddingProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<IdentifyProvider>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final prefService = getIt<PrefService>();
    final initialScreen = prefService.isLoggedIn
        ? const StudentListScreen()
        : const LoginScreen();

    return MaterialApp(
      title: 'iCue Super Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        primaryColor: const Color(0xFF6C63FF),
        scaffoldBackgroundColor: const Color(0xFF0F0C20),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFFFF2A54),
          surface: Color(0xFF15102A),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(fontFamily: 'Inter'),
          bodyMedium: TextStyle(fontFamily: 'Inter'),
        ),
      ),
      home: initialScreen,
    );
  }
}
