import 'package:hive_flutter/hive_flutter.dart';
import '../models/type_acte.dart';
import '../models/acte.dart';

class StorageService {
  static const String actesBoxName = 'actes';
  static const String settingsBoxName = 'settings';

  late Box<Acte> _actesBox;
  late Box<dynamic> _settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    
    Hive.registerAdapter(TypeActeAdapter());
    Hive.registerAdapter(ActeAdapter());
    
    _actesBox = await Hive.openBox<Acte>(actesBoxName);
    _settingsBox = await Hive.openBox(settingsBoxName);
  }

  Box<Acte> get actesBox => _actesBox;
  Box<dynamic> get settingsBox => _settingsBox;

  Future<void> saveActe(Acte acte) async {
    await _actesBox.put(acte.id, acte);
  }

  Future<void> deleteActe(String id) async {
    await _actesBox.delete(id);
  }

  List<Acte> getAllActes() {
    return _actesBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Acte? getActe(String id) {
    return _actesBox.get(id);
  }

  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  dynamic getSetting(String key, {dynamic defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue);
  }

  Future<void> clearAllActes() async {
    await _actesBox.clear();
  }

  Future<String> exportActesToJson() async {
    final actes = getAllActes();
    final List<Map<String, dynamic>> data = actes.map((a) => a.toMap()).toList();
    return '{"actes": $data}';
  }

  Future<void> close() async {
    await _actesBox.close();
    await _settingsBox.close();
  }
}