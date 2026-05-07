import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/actes_provider.dart';
import '../models/type_acte.dart';
import '../services/statistiques_service.dart';
import 'actes_list_screen.dart';
import 'ajout_acte_screen.dart';
import 'statistiques_screen.dart';
import 'export_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actes = ref.watch(actesProvider);
    final stats = ref.watch(statistiquesProvider);
    final dateFormat = DateFormat('dd/MM/yyyy');

    final aujourdhui = DateTime.now();
    final actesAujourdhui = stats.getActesDuJour(aujourdhui);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maieuticienne'),
        backgroundColor: Colors.pink.shade50,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCard(
              context,
              'Aujourd\'hui',
              '${actesAujourdhui.length} actes',
              Icons.today,
              Colors.pink,
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              context,
              'Total actes',
              '${stats.totalActes} actes',
              Icons.list_alt,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              context,
              'Accouchements',
              '${stats.totalAccouchements}',
              Icons.child_care,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              context,
              'Urgences',
              '${stats.totalUrgences}',
              Icons.warning,
              Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              'Types d\'actes récents',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: TypeActe.values.length,
                itemBuilder: (context, index) {
                  final type = TypeActe.values[index];
                  final count = actes.where((a) => a.type == type).length;
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$count',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              type.label,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Actes du jour',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (actesAujourdhui.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text('Aucun acte aujourd\'hui'),
                  ),
                ),
              )
            else
              ...actesAujourdhui.take(5).map((acte) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getColorForType(acte.type),
                    child: Text(
                      acte.type.shortLabel,
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                  title: Text(acte.type.label),
                  subtitle: Text('${acte.lieu} - ${dateFormat.format(acte.date)}'),
                  trailing: acte.dureeMinutes != null
                      ? Text('${acte.dureeMinutes} min')
                      : null,
                ),
              )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AjoutActeScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(context),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodySmall),
                Text(value, style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.pink.shade50),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.local_hospital, size: 48, color: Colors.pink),
                SizedBox(height: 8),
                Text(
                  'Application Maieuticienne',
                  style: TextStyle(color: Colors.black87, fontSize: 18),
                ),
                Text(
                  'Suivi des actes',
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Tableau de bord'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Liste des actes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ActesListScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Statistiques'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatistiquesScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Exporter'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExportScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
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