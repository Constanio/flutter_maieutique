import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/acte.dart';
import '../models/type_acte.dart';
import '../providers/actes_provider.dart';
import 'ajout_acte_screen.dart';
import 'acte_detail_screen.dart';

class ActesListScreen extends ConsumerStatefulWidget {
  const ActesListScreen({super.key});

  @override
  ConsumerState<ActesListScreen> createState() => _ActesListScreenState();
}

class _ActesListScreenState extends ConsumerState<ActesListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actes = ref.watch(actesFiltresProvider);
    final filtre = ref.watch(filtreProvider);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des actes'),
        backgroundColor: Colors.pink.shade50,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: filtre.recherche != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(filtreProvider.notifier).state = filtre.copyWith(clearRecherche: true);
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                ref.read(filtreProvider.notifier).state = filtre.copyWith(recherche: value, clearRecherche: value.isEmpty);
              },
            ),
          ),
          if (filtre.typeFilter != null || filtre.dateDebut != null || filtre.dateFin != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  if (filtre.typeFilter != null)
                    Chip(
                      label: Text(filtre.typeFilter!.label),
                      onDeleted: () {
                        ref.read(filtreProvider.notifier).state = filtre.copyWith(clearTypeFilter: true);
                      },
                    ),
                  if (filtre.dateDebut != null)
                    Chip(
                      label: Text('Du ${dateFormat.format(filtre.dateDebut!)}'),
                      onDeleted: () {
                        ref.read(filtreProvider.notifier).state = filtre.copyWith(clearDateDebut: true);
                      },
                    ),
                  if (filtre.dateFin != null)
                    Chip(
                      label: Text('Au ${dateFormat.format(filtre.dateFin!)}'),
                      onDeleted: () {
                        ref.read(filtreProvider.notifier).state = filtre.copyWith(clearDateFin: true);
                      },
                    ),
                ],
              ),
            ),
          Expanded(
            child: actes.isEmpty
                ? const Center(child: Text('Aucun acte trouvé'))
                : ListView.builder(
                    itemCount: actes.length,
                    itemBuilder: (context, index) {
                      final acte = actes[index];
                      return _buildActeCard(context, acte);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AjoutActeScreen()),
          );
        },
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildActeCard(BuildContext context, Acte acte) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ActeDetailScreen(acte: acte)),
          );
        },
        leading: CircleAvatar(
          backgroundColor: _getColorForType(acte.type),
          child: Text(
            acte.type.shortLabel,
            style: const TextStyle(fontSize: 10, color: Colors.white),
          ),
        ),
        title: Text(acte.type.label),
        subtitle: Text('${acte.lieu} - ${dateFormat.format(acte.date)}'),
        trailing: acte.dureeMinutes != null ? Text('${acte.dureeMinutes} min') : null,
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final filtre = ref.read(filtreProvider);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filtres', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      ref.read(filtreProvider.notifier).state = const FiltreState();
                      Navigator.pop(context);
                    },
                    child: const Text('Réinitialiser'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Type d\'acte'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Tous'),
                    selected: filtre.typeFilter == null,
                    onSelected: (selected) {
                      ref.read(filtreProvider.notifier).state = filtre.copyWith(clearTypeFilter: true);
                    },
                  ),
                  ...TypeActe.values.map((type) => ChoiceChip(
                    label: Text(type.label),
                    selected: filtre.typeFilter == type,
                    onSelected: (selected) {
                      ref.read(filtreProvider.notifier).state = filtre.copyWith(
                        typeFilter: selected ? type : null,
                        clearTypeFilter: !selected,
                      );
                    },
                  )),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Période'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    label: const Text('Aujourd\'hui'),
                    onPressed: () {
                      final now = DateTime.now();
                      final debut = DateTime(now.year, now.month, now.day);
                      ref.read(filtreProvider.notifier).state = filtre.copyWith(
                        dateDebut: debut,
                        dateFin: now,
                      );
                    },
                  ),
                  ActionChip(
                    label: const Text('Ce mois'),
                    onPressed: () {
                      final now = DateTime.now();
                      final debut = DateTime(now.year, now.month, 1);
                      ref.read(filtreProvider.notifier).state = filtre.copyWith(
                        dateDebut: debut,
                        dateFin: now,
                      );
                    },
                  ),
                  ActionChip(
                    label: const Text('Cette année'),
                    onPressed: () {
                      final now = DateTime.now();
                      final debut = DateTime(now.year, 1, 1);
                      ref.read(filtreProvider.notifier).state = filtre.copyWith(
                        dateDebut: debut,
                        dateFin: now,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Appliquer'),
                ),
              ),
            ],
          ),
        );
      },
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