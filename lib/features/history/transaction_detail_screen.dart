import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/models/drop_transaction.dart';

class TransactionDetailScreen extends StatelessWidget {
  final DropTransaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard!'),
        backgroundColor: const Color(0xFF00F5A0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isReceive = transaction.type == TransactionType.receive;
    final timeStr = DateFormat('MMMM dd, yyyy • HH:mm:ss').format(transaction.timestamp);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Drop Detail'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isReceive
                          ? const Color(0xFF00F5A0).withOpacity(0.1)
                          : const Color(0xFFB92BFF).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isReceive ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                      color: isReceive ? const Color(0xFF00F5A0) : const Color(0xFFB92BFF),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${isReceive ? "+" : "-"}${transaction.amountSats} sats',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: isReceive ? const Color(0xFF00F5A0) : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isReceive ? 'Claimed Drop' : 'Created Drop',
                    style: const TextStyle(
                      color: Color(0xFF9E9EAF),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildDetailTile('Status', transaction.status.name.toUpperCase(),
                color: transaction.status == TransactionStatus.success ? Colors.green : Colors.amber),
            _buildDetailTile('Date & Time', timeStr),
            _buildDetailTile('Connected Mint', transaction.mintUrl),
            if (transaction.memo != null) _buildDetailTile('Memo', transaction.memo!),
            _buildDetailTile('Transaction ID', transaction.id),
            const SizedBox(height: 24),
            const Divider(color: Color(0xFF2C2F3E)),
            const SizedBox(height: 16),
            if (transaction.rawToken != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Raw Cashu Token',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  TextButton.icon(
                    onPressed: () => _copyToClipboard(context, transaction.rawToken!, 'Cashu Token'),
                    icon: const Icon(Icons.copy, size: 14),
                    label: const Text('Copy', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 100),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF161820),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2C2F3E)),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    transaction.rawToken!,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFF9E9EAF)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (transaction.rawDebugInfo != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Raw Debug Info',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  TextButton.icon(
                    onPressed: () => _copyToClipboard(context, transaction.rawDebugInfo!, 'Debug Info'),
                    icon: const Icon(Icons.copy, size: 14),
                    label: const Text('Copy', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 120),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF161820),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2C2F3E)),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    transaction.rawDebugInfo!,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFF9E9EAF)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF9E9EAF), fontSize: 13),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: color ?? Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
