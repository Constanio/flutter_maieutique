import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/type_acte.dart';
import '../providers/actes_provider.dart';

class AjoutActeScreen extends ConsumerStatefulWidget {
  const AjoutActeScreen({super.key});

  @override
  ConsumerState<AjoutActeScreen> createState() => _AjoutActeScreenState();
}

class _AjoutActeScreenState extends ConsumerState<AjoutActeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lieuController = TextEditingController();
  final _resultatController = TextEditingController();
  final _observationController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  TypeActe _selectedType = TypeActe.consultationPrenatale;
  int? _dureeMinutes;
  bool _isLoading = false;

  @override
  void dispose() {
    _lieuController.dispose();
    _resultatController.dispose();
    _observationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un acte'),
        backgroundColor: Colors.pink.shade50,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Type d\'acte *'),
              const SizedBox(height: 8),
              DropdownButtonFormField<TypeActe>(
                value: _selectedType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                items: TypeActe.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Date *'),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Heure *'),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_selectedTime.format(context)),
                      const Icon(Icons.access_time),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Lieu *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lieuController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Ex: Hôpital, Domicile, Clinique...',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un lieu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Durée (minutes)'),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _dureeMinutes?.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Durée en minutes',
                ),
                onChanged: (value) {
                  _dureeMinutes = int.tryParse(value);
                },
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Résultat'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _resultatController,
                maxLines: 2,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Résultat de l\'acte',
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Observation'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _observationController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Observations',
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Notes'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Notes supplémentaires',
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveActe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _saveActe() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      await ref.read(actesProvider.notifier).addActe(
        date: dateTime,
        type: _selectedType,
        lieu: _lieuController.text,
        dureeMinutes: _dureeMinutes,
        resultat: _resultatController.text.isEmpty ? null : _resultatController.text,
        observation: _observationController.text.isEmpty ? null : _observationController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Acte enregistré avec succès')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}