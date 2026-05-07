import 'package:hive/hive.dart';

part 'type_acte.g.dart';

@HiveType(typeId: 0)
enum TypeActe {
  @HiveField(0)
  accouchement,
  @HiveField(1)
  consultationPrenatale,
  @HiveField(2)
  consultationPostnatale,
  @HiveField(3)
  urgenceObstetricale,
  @HiveField(4)
  actetechnique,
  @HiveField(5)
  visiteADomincile,
  @HiveField(6)
  autre,
}

extension TypeActeExtension on TypeActe {
  String get label {
    switch (this) {
      case TypeActe.accouchement:
        return 'Accouchement';
      case TypeActe.consultationPrenatale:
        return 'Consultation prénatale';
      case TypeActe.consultationPostnatale:
        return 'Consultation postnatale';
      case TypeActe.urgenceObstetricale:
        return 'Urgence obstétricale';
      case TypeActe.actetechnique:
        return 'Acte technique';
      case TypeActe.visiteADomincile:
        return 'Visite à domicile';
      case TypeActe.autre:
        return 'Autre';
    }
  }

  String get shortLabel {
    switch (this) {
      case TypeActe.accouchement:
        return 'ACCO';
      case TypeActe.consultationPrenatale:
        return 'CPN';
      case TypeActe.consultationPostnatale:
        return 'CPN';
      case TypeActe.urgenceObstetricale:
        return 'URG';
      case TypeActe.actetechnique:
        return 'TECH';
      case TypeActe.visiteADomincile:
        return 'VD';
      case TypeActe.autre:
        return 'AUT';
    }
  }
}