import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/sync_service.dart';

class MetricasScreen extends StatefulWidget {
  const MetricasScreen({super.key});

  @override
  State<MetricasScreen> createState() => _MetricasScreenState();
}

class _MetricasScreenState extends State<MetricasScreen> {
  final SyncService _syncService = SyncService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Métricas e Histórico')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _syncService.getEstudos(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Erro: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('Nenhum estudo registrado ainda.'));

          final estudos = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
          
          // Cálculos de Resumo
          double totalHoras = 0;
          int totalQuestoes = 0;
          int totalAcertos = 0;
          for (var e in estudos) {
            totalHoras += (e['duracao_segundos'] ?? 0) / 3600;
            totalQuestoes += (e['questoes_feitas'] as int? ?? 0);
            totalAcertos += (e['questoes_acertadas'] as int? ?? 0);
          }
          double taxaAcerto = totalQuestoes > 0 ? (totalAcertos / totalQuestoes) * 100 : 0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildResumoCards(totalHoras, totalQuestoes, taxaAcerto, estudos.length),
              
              const SizedBox(height: 24),
              const Text('Desempenho por Matéria', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: _buildPieSections(estudos),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              const Text('Histórico Recente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              ...estudos.map((estudo) {
                final dataStr = estudo['data'] as String?;
                final data = dataStr != null ? DateTime.parse(dataStr) : DateTime.now();
                final duracao = Duration(seconds: estudo['duracao_segundos'] ?? 0);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(estudo['materia'] ?? 'Sem Matéria', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${DateFormat('dd/MM/yyyy').format(data)} • ${duracao.inMinutes} min'),
                    trailing: Text('${estudo['questoes_acertadas'] ?? 0}/${estudo['questoes_feitas'] ?? 0} acertos', 
                      style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/inicio');
          if (index == 2) Navigator.pushReplacementNamed(context, '/perfil');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.history_edu), label: 'Estudo'),
          BottomNavigationBarItem(icon: Icon(Icons.insert_chart), label: 'Métricas'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildResumoCards(double horas, int questoes, double taxa, int sessoes) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard('Horas Líquidas', '${horas.toStringAsFixed(1)}h', Colors.blue),
        _buildMetricCard('Questões', questoes.toString(), Colors.green),
        _buildMetricCard('Taxa de Acerto', '${taxa.toStringAsFixed(1)}%', Colors.orange),
        _buildMetricCard('Sessões', sessoes.toString(), Colors.purple),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: color.withOpacity(0.3))),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(List<Map<String, dynamic>> estudos) {
    final Map<String, int> materiaTempo = {};
    for (var e in estudos) {
      final materia = e['materia'] as String? ?? 'Outros';
      materiaTempo[materia] = (materiaTempo[materia] ?? 0) + (e['duracao_segundos'] as int? ?? 0);
    }

    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red, Colors.teal];
    int i = 0;
    
    return materiaTempo.entries.map((entry) {
      final color = colors[i % colors.length];
      i++;
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: entry.key,
        radius: 50,
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }
}
