import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../providers/actes_provider.dart';
import '../services/storage_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Colors.pink.shade50,
      ),
      body: ListView(
        children: [
          _buildSection('Sécurité'),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Changer le code PIN'),
            onTap: () => _changePin(context, ref),
          ),
          const Divider(),
          _buildSection('Données'),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('Exporter les données (JSON)'),
            onTap: () => _exportJson(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Importer des données (JSON)'),
            onTap: () => _importJson(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Supprimer toutes les données', style: TextStyle(color: Colors.red)),
            onTap: () => _confirmDeleteAll(context, ref),
          ),
          const Divider(),
          _buildSection('À propos'),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          const ListTile(
            leading: Icon(Icons.local_hospital),
            title: Text('Application Maieuticienne'),
            subtitle: Text('Suivi des actes'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.pink,
        ),
      ),
    );
  }

  void _changePin(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer le code PIN'),
        content: const Text('Fonctionnalité en développement'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportJson(BuildContext context, WidgetRef ref) async {
    try {
      final storage = ref.read(storageServiceProvider);
      final json = await storage.exportActesToJson();
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(json);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exporté: ${file.path}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _importJson(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importer'),
        content: const Text('Fonctionnalité en développement'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer toutes les données? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final storage = ref.read(storageServiceProvider);
              await storage.clearAllActes();
              ref.read(actesProvider.notifier).refresh();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Données supprimées')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}