import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/acte.dart';
import 'models/type_acte.dart';
import 'services/storage_service.dart';
import 'services/statistiques_service.dart';
import 'services/export_service.dart';
import 'providers/actes_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final storageService = StorageService();
  await storageService.init();
  
  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const MaieuticienneApp(),
    ),
  );
}

class MaieuticienneApp extends ConsumerStatefulWidget {
  const MaieuticienneApp({super.key});

  @override
  ConsumerState<MaieuticienneApp> createState() => _MaieuticienneAppState();
}

class _MaieuticienneAppState extends ConsumerState<MaieuticienneApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maieuticienne',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}