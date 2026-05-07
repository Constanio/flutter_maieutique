import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/acte.dart';
import '../models/type_acte.dart';
import '../providers/actes_provider.dart';

class ActeDetailScreen extends ConsumerWidget {
  final Acte acte;

  const ActeDetailScreen({super.key, required this.acte});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail de l\'acte'),
        backgroundColor: Colors.pink.shade50,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editActe(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: _getColorForType(acte.type),
                          radius: 24,
                          child: Text(
                            acte.type.shortLabel,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                acte.type.label,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                dateFormat.format(acte.date),
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Date', dateFormat.format(acte.date)),
            _buildInfoRow('Heure', timeFormat.format(acte.date)),
            _buildInfoRow('Lieu', acte.lieu),
            if (acte.dureeMinutes != null) _buildInfoRow('Durée', '${acte.dureeMinutes} minutes'),
            if (acte.resultat != null && acte.resultat!.isNotEmpty)
              _buildInfoRow('Résultat', acte.resultat!),
            if (acte.observation != null && acte.observation!.isNotEmpty)
              _buildSection('Observation', acte.observation!),
            if (acte.notes != null && acte.notes!.isNotEmpty)
              _buildSection('Notes', acte.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(content),
          ),
        ],
      ),
    );
  }

  void _editActe(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier l\'acte'),
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

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cet acte? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(actesProvider.notifier).deleteActe(acte.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Acte supprimé')),
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

  Color _getColorForType(TypeActe type) {
    switch (type) {
      case TypeActe.accouchement:
        return Colors.green;
      case TypeActe.consultationPrenatale:
        return Colors.blue;
      case TypeActe.consultationPostnatale:
        return Colors.indigo;
      case TypeActe.urgenceObstetricale:
        return Colors.red;
      case TypeActe.actetechnique:
        return Colors.orange;
      case TypeActe.visiteADomincile:
        return Colors.purple;
      case TypeActe.autre:
        return Colors.grey;
    }
  }
}