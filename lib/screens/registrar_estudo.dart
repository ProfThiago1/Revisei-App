import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import '../providers/timer_provider.dart';
import '../providers/theme_provider.dart';
import '../services/sync_service.dart';

class RegistrarEstudoScreen extends StatefulWidget {
  const RegistrarEstudoScreen({super.key});

  @override
  State<RegistrarEstudoScreen> createState() => _RegistrarEstudoScreenState();
}

class _RegistrarEstudoScreenState extends State<RegistrarEstudoScreen> {
  final TextEditingController _materiaController = TextEditingController();
  final TextEditingController _questoesController = TextEditingController();
  final TextEditingController _acertosController = TextEditingController();
  final QuillController _anotacoesController = QuillController.basic();
  bool _mostrarToolbar = false;
  final SyncService _syncService = SyncService();

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                'Sessão de Estudo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 32),
              
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: timerProvider.progress,
                      strokeWidth: 12,
                      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    ),
                  ),
                  Text(
                    timerProvider.formattedTime,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: timerProvider.isRunning 
                      ? timerProvider.pauseTimer 
                      : timerProvider.startTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(timerProvider.isRunning ? 'Pausar' : 'Iniciar'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: timerProvider.resetTimer,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Resetar'),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              TextButton.icon(
                onPressed: () => _showTimePicker(context, timerProvider),
                icon: const Icon(Icons.timer_outlined),
                label: const Text('Definir Duração'),
              ),
              
              const SizedBox(height: 32),
              
              TextField(
                controller: _materiaController,
                decoration: InputDecoration(
                  labelText: 'Matéria estudada',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.book),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _questoesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Questões',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _acertosController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Acertos',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Anotações", style: TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: Icon(_mostrarToolbar ? Icons.close : Icons.edit, size: 20),
                      onPressed: () => setState(() => _mostrarToolbar = !_mostrarToolbar),
                    ),
                  ],
                ),
              ),
              if (_mostrarToolbar)
                QuillSimpleToolbar(
                  controller: _anotacoesController,
                  config: const QuillSimpleToolbarConfig(),
                ),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: QuillEditor.basic(
                  controller: _anotacoesController,
                  config: const QuillEditorConfig(
                    placeholder: "O que você aprendeu hoje?",
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => _salvarSessao(context, timerProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Finalizar e Salvar Sessão', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) Navigator.pushReplacementNamed(context, '/metricas');
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

  Future<void> _salvarSessao(BuildContext context, TimerProvider timerProvider) async {
    if (_materiaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, insira a matéria.')));
      return;
    }

    final anotacoesJson = jsonEncode(_anotacoesController.document.toDelta().toJson());

    try {
      await _syncService.salvarEstudo({
        'materia': _materiaController.text,
        'data': DateTime.now().toIso8601String(),
        'duracao_segundos': timerProvider.totalSeconds - timerProvider.secondsRemaining,
        'questoes_feitas': int.tryParse(_questoesController.text) ?? 0,
        'questoes_acertadas': int.tryParse(_acertosController.text) ?? 0,
        'anotacoes': anotacoesJson
      });

      timerProvider.resetTimer();
      _materiaController.clear();
      _questoesController.clear();
      _acertosController.clear();
      _anotacoesController.clear();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sessão de estudo sincronizada com sucesso!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    }
  }

  void _showTimePicker(BuildContext context, TimerProvider provider) {
    int hours = provider.totalSeconds ~/ 3600;
    int minutes = (provider.totalSeconds % 3600) ~/ 60;
    int seconds = provider.totalSeconds % 60;

    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 300,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Definir duração', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Row(
                children: [
                  _buildPicker(List.generate(24, (i) => '$i h'), (val) => hours = val, hours),
                  _buildPicker(List.generate(60, (i) => '$i m'), (val) => minutes = val, minutes),
                  _buildPicker(List.generate(60, (i) => '$i s'), (val) => seconds = val, seconds),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                provider.setDuration(Duration(hours: hours, minutes: minutes, seconds: seconds));
                Navigator.pop(context);
              },
              child: const Text('Confirmar'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPicker(List<String> items, Function(int) onSelected, int initialItem) {
    return Expanded(
      child: CupertinoPicker(
        itemExtent: 40,
        scrollController: FixedExtentScrollController(initialItem: initialItem),
        onSelectedItemChanged: onSelected,
        children: items.map((item) => Center(child: Text(item))).toList(),
      ),
    );
  }
}
