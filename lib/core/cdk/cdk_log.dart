import 'package:flutter_riverpod/flutter_riverpod.dart';

class CdkLog {
  final String id;
  final String methodName;
  final String status; // 'SUCCESS', 'ERROR', 'PENDING', 'INFO'
  final String message;
  final DateTime timestamp;
  final String? rawResponseOrError;

  CdkLog({
    required this.id,
    required this.methodName,
    required this.status,
    required this.message,
    required this.timestamp,
    this.rawResponseOrError,
  });
}

class CdkLogNotifier extends StateNotifier<List<CdkLog>> {
  CdkLogNotifier() : super([]);

  void log(String methodName, String status, String message, {String? rawResponseOrError}) {
    final newLog = CdkLog(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      methodName: methodName,
      status: status,
      message: message,
      timestamp: DateTime.now(),
      rawResponseOrError: rawResponseOrError,
    );
    state = [newLog, ...state];
  }

  void clear() {
    state = [];
  }
}

final cdkLogProvider = StateNotifierProvider<CdkLogNotifier, List<CdkLog>>((ref) {
  return CdkLogNotifier();
});
