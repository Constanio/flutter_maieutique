// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'type_acte.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TypeActeAdapter extends TypeAdapter<TypeActe> {
  @override
  final int typeId = 0;

  @override
  TypeActe read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TypeActe.accouchement;
      case 1:
        return TypeActe.consultationPrenatale;
      case 2:
        return TypeActe.consultationPostnatale;
      case 3:
        return TypeActe.urgenceObstetricale;
      case 4:
        return TypeActe.actetechnique;
      case 5:
        return TypeActe.visiteADomincile;
      case 6:
        return TypeActe.autre;
      default:
        return TypeActe.accouchement;
    }
  }

  @override
  void write(BinaryWriter writer, TypeActe obj) {
    switch (obj) {
      case TypeActe.accouchement:
        writer.writeByte(0);
        break;
      case TypeActe.consultationPrenatale:
        writer.writeByte(1);
        break;
      case TypeActe.consultationPostnatale:
        writer.writeByte(2);
        break;
      case TypeActe.urgenceObstetricale:
        writer.writeByte(3);
        break;
      case TypeActe.actetechnique:
        writer.writeByte(4);
        break;
      case TypeActe.visiteADomincile:
        writer.writeByte(5);
        break;
      case TypeActe.autre:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TypeActeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
