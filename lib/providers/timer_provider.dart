import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerProvider with ChangeNotifier {
  Timer? _timer;
  int _secondsRemaining = 25 * 60;
  int _totalSeconds = 25 * 60;
  bool _isRunning = false;
  
  int get secondsRemaining => _secondsRemaining;
  int get totalSeconds => _totalSeconds;
  bool get isRunning => _isRunning;
  double get progress => _totalSeconds > 0 ? (_totalSeconds - _secondsRemaining) / _totalSeconds : 0;

  TimerProvider() {
    _checkBackgroundTimer();
  }

  void setDuration(Duration duration) {
    _totalSeconds = duration.inSeconds;
    _secondsRemaining = _totalSeconds;
    notifyListeners();
  }

  void startTimer() async {
    if (_isRunning) return;
    _isRunning = true;
    
    // Salva o timestamp de término esperado
    final endTime = DateTime.now().add(Duration(seconds: _secondsRemaining));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('timer_end_timestamp', endTime.millisecondsSinceEpoch);
    await prefs.setBool('timer_is_running', true);
    await prefs.setInt('timer_total_seconds', _totalSeconds);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        stopTimer();
      }
    });
    notifyListeners();
  }

  void pauseTimer() async {
    _timer?.cancel();
    _isRunning = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('timer_is_running', false);
    notifyListeners();
  }

  void stopTimer() async {
    _timer?.cancel();
    _isRunning = false;
    _secondsRemaining = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('timer_end_timestamp');
    await prefs.setBool('timer_is_running', false);
    notifyListeners();
  }

  void resetTimer() async {
    _timer?.cancel();
    _isRunning = false;
    _secondsRemaining = _totalSeconds;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('timer_end_timestamp');
    await prefs.setBool('timer_is_running', false);
    notifyListeners();
  }

  void _checkBackgroundTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final isRunning = prefs.getBool('timer_is_running') ?? false;
    final endTimestamp = prefs.getInt('timer_end_timestamp');
    _totalSeconds = prefs.getInt('timer_total_seconds') ?? (25 * 60);

    if (isRunning && endTimestamp != null) {
      final endTime = DateTime.fromMillisecondsSinceEpoch(endTimestamp);
      final now = DateTime.now();
      final difference = endTime.difference(now).inSeconds;

      if (difference > 0) {
        _secondsRemaining = difference;
        startTimer(); // Retoma o timer com o tempo restante calculado
      } else {
        _secondsRemaining = 0;
        _isRunning = false;
        await prefs.setBool('timer_is_running', false);
      }
    } else {
      _secondsRemaining = _totalSeconds;
    }
    notifyListeners();
  }

  String get formattedTime {
    int h = _secondsRemaining ~/ 3600;
    int m = (_secondsRemaining % 3600) ~/ 60;
    int s = _secondsRemaining % 60;
    
    if (h > 0) {
      return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
    }
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }
}
