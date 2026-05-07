// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'acte.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActeAdapter extends TypeAdapter<Acte> {
  @override
  final int typeId = 1;

  @override
  Acte read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Acte(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      type: fields[2] as TypeActe,
      lieu: fields[3] as String,
      dureeMinutes: fields[4] as int?,
      resultat: fields[5] as String?,
      observation: fields[6] as String?,
      notes: fields[7] as String?,
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Acte obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.lieu)
      ..writeByte(4)
      ..write(obj.dureeMinutes)
      ..writeByte(5)
      ..write(obj.resultat)
      ..writeByte(6)
      ..write(obj.observation)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
