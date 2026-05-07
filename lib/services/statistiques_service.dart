import '../models/acte.dart';
import '../models/type_acte.dart';

class StatistiquesService {
  final List<Acte> actes;

  StatistiquesService(this.actes);

  int get totalActes => actes.length;

  int get totalAccouchements => actes.where((a) => a.type == TypeActe.accouchement).length;

  int get totalConsultationsPrenatales => actes.where((a) => a.type == TypeActe.consultationPrenatale).length;

  int get totalConsultationsPostnatales => actes.where((a) => a.type == TypeActe.consultationPostnatale).length;

  int get totalUrgences => actes.where((a) => a.type == TypeActe.urgenceObstetricale).length;

  int get totalVisitesADomicile => actes.where((a) => a.type == TypeActe.visiteADomincile).length;

  int get totalActesTechniques => actes.where((a) => a.type == TypeActe.actetechnique).length;

  int get totalAutre => actes.where((a) => a.type == TypeActe.autre).length;

  int getDureeTotaleMinutes() {
    return actes.fold(0, (sum, a) => sum + (a.dureeMinutes ?? 0));
  }

  String getDureeTotaleFormatee() {
    final totalMinutes = getDureeTotaleMinutes();
    final heures = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${heures}h ${minutes}min';
  }

  Map<TypeActe, int> getRepartitionParType() {
    final Map<TypeActe, int> repartition = {};
    for (final type in TypeActe.values) {
      final count = actes.where((a) => a.type == type).length;
      if (count > 0) {
        repartition[type] = count;
      }
    }
    return repartition;
  }

  List<Acte> getActesParPeriode(DateTime debut, DateTime fin) {
    return actes.where((a) => a.date.isAfter(debut) && a.date.isBefore(fin.add(const Duration(days: 1)))).toList();
  }

  List<Acte> getActesDuJour(DateTime date) {
    final debut = DateTime(date.year, date.month, date.day);
    final fin = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return getActesParPeriode(debut, fin);
  }

  List<Acte> getActesDuMois(int year, int month) {
    final debut = DateTime(year, month, 1);
    final fin = DateTime(year, month + 1, 0);
    return getActesParPeriode(debut, fin);
  }

  List<Acte> getActesDeAnnee(int year) {
    final debut = DateTime(year, 1, 1);
    final fin = DateTime(year, 12, 31);
    return getActesParPeriode(debut, fin);
  }

  Map<int, int> getActesParJour_duMois(int year, int month) {
    final jours = <int, int>{};
    final actesDuMois = getActesDuMois(year, month);
    for (final acte in actesDuMois) {
      final jour = acte.date.day;
      jours[jour] = (jours[jour] ?? 0) + 1;
    }
    return jours;
  }

  Map<TypeActe, int> getStatistiquesPeriode(DateTime debut, DateTime fin) {
    final actesPeriode = getActesParPeriode(debut, fin);
    final service = StatistiquesService(actesPeriode);
    return service.getRepartitionParType();
  }
}