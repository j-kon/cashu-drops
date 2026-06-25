import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/cdk/cdk_log.dart';

class DeveloperConsoleScreen extends ConsumerWidget {
  const DeveloperConsoleScreen({super.key});

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'SUCCESS':
        return const Color(0xFF00F5A0);
      case 'ERROR':
        return const Color(0xFFFF5252);
      case 'PENDING':
        return Colors.amber;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(cdkLogProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Console'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Clear Logs',
            onPressed: () {
              ref.read(cdkLogProvider.notifier).clear();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: logs.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E212B),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.terminal_rounded, size: 48, color: Color(0xFF9E9EAF)),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No logs captured yet',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Perform wallet operations to capture CDK events.',
                      style: TextStyle(color: Color(0xFF9E9EAF), fontSize: 13),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final statusColor = _getStatusColor(log.status);
                  final timeStr = DateFormat('HH:mm:ss.SSS').format(log.timestamp);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      leading: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          log.status,
                          style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        log.methodName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(log.message, style: const TextStyle(fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(timeStr, style: const TextStyle(color: Color(0xFF9E9EAF), fontSize: 10)),
                        ],
                      ),
                      childrenPadding: const EdgeInsets.all(16),
                      children: [
                        if (log.rawResponseOrError != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Raw Payload / Error:',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 14, color: Color(0xFF00F5A0)),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: log.rawResponseOrError!));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Copied payload to clipboard')),
                                  );
                                },
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D0E12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF2C2F3E)),
                            ),
                            child: SelectableText(
                              log.rawResponseOrError!,
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                            ),
                          ),
                        ] else
                          const Text('No extra payload or metadata was provided with this log.',
                              style: TextStyle(fontSize: 11, color: Color(0xFF9E9EAF))),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
