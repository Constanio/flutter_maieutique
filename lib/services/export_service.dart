import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/acte.dart';
import '../models/type_acte.dart';

class ExportService {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  Future<String> exportToCsv(List<Acte> actes, {String? filename}) async {
    final List<List<dynamic>> rows = [
      ['ID', 'Date', 'Heure', 'Type', 'Lieu', 'Durée (min)', 'Résultat', 'Observation', 'Notes'],
    ];

    for (final acte in actes) {
      rows.add([
        acte.id,
        _dateFormat.format(acte.date),
        DateFormat('HH:mm').format(acte.date),
        acte.type.label,
        acte.lieu,
        acte.dureeMinutes ?? '',
        acte.resultat ?? '',
        acte.observation ?? '',
        acte.notes ?? '',
      ]);
    }

    final String csv = const ListToCsvConverter().convert(rows);
    
    final directory = await getApplicationDocumentsDirectory();
    final fileName = filename ?? 'actes_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(csv);
    
    return file.path;
  }

  Future<String> exportToPdf(List<Acte> actes, {String? filename}) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Rapport des actes',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Généré le ${_dateTimeFormat.format(DateTime.now())}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: _buildTableRowsPdf(actes),
            ),
          ];
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final fileName = filename ?? 'actes_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  List<pw.TableRow> _buildTableRowsPdf(List<Acte> actes) {
    return [
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
        children: [
          _headerCell('Date'),
          _headerCell('Type'),
          _headerCell('Lieu'),
          _headerCell('Durée'),
          _headerCell('Résultat'),
        ],
      ),
      ...actes.map((a) => pw.TableRow(
        children: [
          _cell(_dateFormat.format(a.date)),
          _cell(a.type.label),
          _cell(a.lieu),
          _cell(a.dureeMinutes != null ? '${a.dureeMinutes} min' : '-'),
          _cell(a.resultat ?? '-'),
        ],
      )),
    ];
  }

  pw.Widget _headerCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
    );
  }

  pw.Widget _cell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 8)),
    );
  }

  String generateRapportText(List<Acte> actes) {
    final buffer = StringBuffer();
    buffer.writeln('=====================================');
    buffer.writeln('RAPPORT DES ACTES');
    buffer.writeln('=====================================');
    buffer.writeln('Généré le: ${_dateTimeFormat.format(DateTime.now())}');
    buffer.writeln('');
    buffer.writeln('Total des actes: ${actes.length}');
    buffer.writeln('');

    final stats = <TypeActe, int>{};
    for (final acte in actes) {
      stats[acte.type] = (stats[acte.type] ?? 0) + 1;
    }

    buffer.writeln('Répartition par type:');
    for (final entry in stats.entries) {
      buffer.writeln('  - ${entry.key.label}: ${entry.value}');
    }

    buffer.writeln('');
    buffer.writeln('=====================================');
    buffer.writeln('LISTE DES ACTES');
    buffer.writeln('=====================================');

    for (final acte in actes) {
      buffer.writeln('');
      buffer.writeln('[${_dateFormat.format(acte.date)}] ${acte.type.label}');
      buffer.writeln('  Lieu: ${acte.lieu}');
      if (acte.dureeMinutes != null) {
        buffer.writeln('  Durée: ${acte.dureeMinutes} min');
      }
      if (acte.resultat != null && acte.resultat!.isNotEmpty) {
        buffer.writeln('  Résultat: ${acte.resultat}');
      }
      if (acte.observation != null && acte.observation!.isNotEmpty) {
        buffer.writeln('  Observation: ${acte.observation}');
      }
    }

    return buffer.toString();
  }
}