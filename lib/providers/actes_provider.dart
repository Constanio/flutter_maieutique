import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/acte.dart';
import '../models/type_acte.dart';
import '../services/storage_service.dart';
import '../services/statistiques_service.dart';
import '../services/export_service.dart';
import 'package:uuid/uuid.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('Storage service must be initialized');
});

final actesProvider = StateNotifierProvider<ActesNotifier, List<Acte>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ActesNotifier(storage);
});

class ActesNotifier extends StateNotifier<List<Acte>> {
  final StorageService _storage;

  ActesNotifier(this._storage) : super([]) {
    _loadActes();
  }

  void _loadActes() {
    state = _storage.getAllActes();
  }

  Future<void> addActe({
    required DateTime date,
    required TypeActe type,
    required String lieu,
    int? dureeMinutes,
    String? resultat,
    String? observation,
    String? notes,
  }) async {
    final now = DateTime.now();
    final acte = Acte(
      id: const Uuid().v4(),
      date: date,
      type: type,
      lieu: lieu,
      dureeMinutes: dureeMinutes,
      resultat: resultat,
      observation: observation,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );

    await _storage.saveActe(acte);
    _loadActes();
  }

  Future<void> updateActe(Acte acte) async {
    final updated = acte.copyWith(updatedAt: DateTime.now());
    await _storage.saveActe(updated);
    _loadActes();
  }

  Future<void> deleteActe(String id) async {
    await _storage.deleteActe(id);
    _loadActes();
  }

  void refresh() {
    _loadActes();
  }
}

final statistiquesProvider = Provider<StatistiquesService>((ref) {
  final actes = ref.watch(actesProvider);
  return StatistiquesService(actes);
});

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService();
});

class FiltreState {
  final String? recherche;
  final TypeActe? typeFilter;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final String? lieu;

  const FiltreState({
    this.recherche,
    this.typeFilter,
    this.dateDebut,
    this.dateFin,
    this.lieu,
  });

  FiltreState copyWith({
    String? recherche,
    TypeActe? typeFilter,
    DateTime? dateDebut,
    DateTime? dateFin,
    String? lieu,
    bool clearRecherche = false,
    bool clearTypeFilter = false,
    bool clearDateDebut = false,
    bool clearDateFin = false,
    bool clearLieu = false,
  }) {
    return FiltreState(
      recherche: clearRecherche ? null : (recherche ?? this.recherche),
      typeFilter: clearTypeFilter ? null : (typeFilter ?? this.typeFilter),
      dateDebut: clearDateDebut ? null : (dateDebut ?? this.dateDebut),
      dateFin: clearDateFin ? null : (dateFin ?? this.dateFin),
      lieu: clearLieu ? null : (lieu ?? this.lieu),
    );
  }
}

final filtreProvider = StateProvider<FiltreState>((ref) => const FiltreState());

final actesFiltresProvider = Provider<List<Acte>>((ref) {
  final actes = ref.watch(actesProvider);
  final filtre = ref.watch(filtreProvider);

  var resultats = actes;

  if (filtre.recherche != null && filtre.recherche!.isNotEmpty) {
    final search = filtre.recherche!.toLowerCase();
    resultats = resultats.where((a) {
      return a.lieu.toLowerCase().contains(search) ||
          (a.observation?.toLowerCase().contains(search) ?? false) ||
          (a.resultat?.toLowerCase().contains(search) ?? false) ||
          (a.notes?.toLowerCase().contains(search) ?? false);
    }).toList();
  }

  if (filtre.typeFilter != null) {
    resultats = resultats.where((a) => a.type == filtre.typeFilter).toList();
  }

  if (filtre.dateDebut != null) {
    resultats = resultats.where((a) => a.date.isAfter(filtre.dateDebut!)).toList();
  }

  if (filtre.dateFin != null) {
    resultats = resultats.where((a) => a.date.isBefore(filtre.dateFin!.add(const Duration(days: 1)))).toList();
  }

  if (filtre.lieu != null && filtre.lieu!.isNotEmpty) {
    resultats = resultats.where((a) => a.lieu.toLowerCase() == filtre.lieu!.toLowerCase()).toList();
  }

  return resultats;
});