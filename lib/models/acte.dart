import 'package:hive/hive.dart';

import 'type_acte.dart';

part 'acte.g.dart';

@HiveType(typeId: 1)
class Acte extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final TypeActe type;

  @HiveField(3)
  final String lieu;

  @HiveField(4)
  final int? dureeMinutes;

  @HiveField(5)
  final String? resultat;

  @HiveField(6)
  final String? observation;

  @HiveField(7)
  final String? notes;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime updatedAt;

  Acte({
    required this.id,
    required this.date,
    required this.type,
    required this.lieu,
    this.dureeMinutes,
    this.resultat,
    this.observation,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Acte copyWith({
    String? id,
    DateTime? date,
    TypeActe? type,
    String? lieu,
    int? dureeMinutes,
    String? resultat,
    String? observation,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Acte(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      lieu: lieu ?? this.lieu,
      dureeMinutes: dureeMinutes ?? this.dureeMinutes,
      resultat: resultat ?? this.resultat,
      observation: observation ?? this.observation,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type.name,
      'lieu': lieu,
      'dureeMinutes': dureeMinutes,
      'resultat': resultat,
      'observation': observation,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Acte.fromMap(Map<String, dynamic> map) {
    return Acte(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      type: TypeActe.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TypeActe.autre,
      ),
      lieu: map['lieu'] as String,
      dureeMinutes: map['dureeMinutes'] as int?,
      resultat: map['resultat'] as String?,
      observation: map['observation'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}