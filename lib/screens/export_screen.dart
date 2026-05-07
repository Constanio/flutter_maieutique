import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../models/acte.dart';
import '../models/type_acte.dart';
import '../providers/actes_provider.dart';
import '../services/export_service.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  TypeActe? _selectedType;
  DateTime? _dateDebut;
  DateTime? _dateFin;
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exporter'),
        backgroundColor: Colors.pink.shade50,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Filtres'),
            const SizedBox(height: 12),
            _buildFilterSection(),
            const SizedBox(height: 24),
            _buildSectionTitle('Exporter en PDF'),
            const SizedBox(height: 12),
            _buildExportButton(
              'Exporter en PDF',
              Icons.picture_as_pdf,
              () => _exportPdf(),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Exporter en CSV'),
            const SizedBox(height: 12),
            _buildExportButton(
              'Exporter en CSV',
              Icons.table_chart,
              () => _exportCsv(),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Aperçu'),
            const SizedBox(height: 12),
            _buildApercu(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildFilterSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Type d\'acte'),
            const SizedBox(height: 8),
            DropdownButtonFormField<TypeActe?>(
              value: _selectedType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Tous')),
                ...TypeActe.values.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.label),
                )),
              ],
              onChanged: (value) => setState(() => _selectedType = value),
            ),
            const SizedBox(height: 16),
            const Text('Date de début'),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDateDebut,
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_dateDebut != null
                        ? DateFormat('dd/MM/yyyy').format(_dateDebut!)
                        : 'Toutes les dates'),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Date de fin'),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDateFin,
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_dateFin != null
                        ? DateFormat('dd/MM/yyyy').format(_dateFin!)
                        : 'Toutes les dates'),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton(String label, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isExporting ? null : onPressed,
        icon: _isExporting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon),
        label: Text(_isExporting ? 'Export en cours...' : label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildApercu() {
    final actes = _getFilteredActes();
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${actes.length} acte(s) à exporter'),
            if (_selectedType != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Type: ${_selectedType!.label}'),
              ),
            if (_dateDebut != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Du: ${dateFormat.format(_dateDebut!)}'),
              ),
            if (_dateFin != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Au: ${dateFormat.format(_dateFin!)}'),
              ),
            if (actes.isNotEmpty) ...[
              const Divider(),
              const Text('Aperçu:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...actes.take(5).map((acte) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '- ${dateFormat.format(acte.date)}: ${acte.type.label} (${acte.lieu})',
                  style: const TextStyle(fontSize: 12),
                ),
              )),
              if (actes.length > 5)
                Text(
                  '... et ${actes.length - 5} autres',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
            ],
          ],
        ),
      ),
    );
  }

  List<Acte> _getFilteredActes() {
    var actes = ref.read(actesProvider);
    if (_selectedType != null) {
      actes = actes.where((a) => a.type == _selectedType).toList();
    }
    if (_dateDebut != null) {
      actes = actes.where((a) => a.date.isAfter(_dateDebut!)).toList();
    }
    if (_dateFin != null) {
      actes = actes.where((a) => a.date.isBefore(_dateFin!.add(const Duration(days: 1)))).toList();
    }
    return actes;
  }

  Future<void> _selectDateDebut() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateDebut ?? DateTime(2020),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _dateDebut = date);
    }
  }

  Future<void> _selectDateFin() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateFin ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _dateFin = date);
    }
  }

  Future<void> _exportPdf() async {
    setState(() => _isExporting = true);
    try {
      final exportService = ref.read(exportServiceProvider);
      final actes = _getFilteredActes();
      final path = await exportService.exportToPdf(actes);
      await Share.shareXFiles([XFile(path)], text: 'Rapport des actes');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _exportCsv() async {
    setState(() => _isExporting = true);
    try {
      final exportService = ref.read(exportServiceProvider);
      final actes = _getFilteredActes();
      final path = await exportService.exportToCsv(actes);
      await Share.shareXFiles([XFile(path)], text: 'Export des actes');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
}