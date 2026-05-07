import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/type_acte.dart';
import '../providers/actes_provider.dart';
import '../services/statistiques_service.dart';

class StatistiquesScreen extends ConsumerStatefulWidget {
  const StatistiquesScreen({super.key});

  @override
  ConsumerState<StatistiquesScreen> createState() => _StatistiquesScreenState();
}

class _StatistiquesScreenState extends ConsumerState<StatistiquesScreen> {
  int _selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statistiquesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        backgroundColor: Colors.pink.shade50,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Vue d\'ensemble'),
            const SizedBox(height: 12),
            _buildOverviewCards(stats),
            const SizedBox(height: 24),
            _buildSectionTitle('Répartition par type'),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: _buildPieChart(stats),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Actes par mois ($_selectedYear)'),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: _buildBarChart(),
            ),
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

  Widget _buildOverviewCards(StatistiquesService stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      childAspectRatio: 1.5,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard('Total actes', '${stats.totalActes}', Icons.list_alt, Colors.blue),
        _buildStatCard('Accouchements', '${stats.totalAccouchements}', Icons.child_care, Colors.green),
        _buildStatCard('Consultations', '${stats.totalConsultationsPrenatales + stats.totalConsultationsPostnatales}', Icons.medical_services, Colors.indigo),
        _buildStatCard('Urgences', '${stats.totalUrgences}', Icons.priority_high, Colors.red),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(StatistiquesService stats) {
    final repartition = stats.getRepartitionParType();
    if (repartition.isEmpty) {
      return const Center(child: Text('Aucune donnée'));
    }

    final sections = repartition.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${entry.value}',
        color: _getColorForType(entry.key),
        radius: 60,
        titleStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
      );
    }).toList();

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: repartition.keys.map((type) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getColorForType(type),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(type.label, style: const TextStyle(fontSize: 10)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    final stats = ref.watch(statistiquesProvider);
    final actesParMois = <int, int>{};

    for (int i = 1; i <= 12; i++) {
      final debut = DateTime(_selectedYear, i, 1);
      final fin = DateTime(_selectedYear, i + 1, 0);
      actesParMois[i] = stats.getActesParPeriode(debut, fin).length;
    }

    final spots = actesParMois.entries.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList();

    return BarChart(
      BarChartData(
        barGroups: List.generate(12, (i) {
          return BarChartGroupData(
            x: i + 1,
            barRods: [
              BarChartRodData(
                toY: actesParMois[i + 1]!.toDouble(),
                color: Colors.pink,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const mois = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
                final index = value.toInt() - 1;
                if (index >= 0 && index < 12) {
                  return Text(mois[index], style: const TextStyle(fontSize: 10));
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
      ),
    );
  }

  Color _getColorForType(TypeActe type) {
    switch (type) {
      case TypeActe.accouchement:
        return Colors.green;
      case TypeActe.consultationPrenatale:
        return Colors.blue;
      case TypeActe.consultationPostnatale:
        return Colors.indigo;
      case TypeActe.urgenceObstetricale:
        return Colors.red;
      case TypeActe.actetechnique:
        return Colors.orange;
      case TypeActe.visiteADomincile:
        return Colors.purple;
      case TypeActe.autre:
        return Colors.grey;
    }
  }
}