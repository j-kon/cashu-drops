import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/cdk/cdk_service_provider.dart';
import '../../core/models/drop_transaction.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletNotifierProvider);
    final transactions = walletState.transactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Drop History'),
      ),
      body: SafeArea(
        child: transactions.isEmpty
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
                      child: const Icon(Icons.history_toggle_off_rounded, size: 48, color: Color(0xFF9E9EAF)),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No drop history yet',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Send or receive drops to see them listed here.',
                      style: TextStyle(color: Color(0xFF9E9EAF), fontSize: 13),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: transactions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  final isReceive = tx.type == TransactionType.receive;
                  final timeStr = DateFormat('MMM dd, yyyy • HH:mm').format(tx.timestamp);

                  return Card(
                    child: InkWell(
                      onTap: () => context.push('/transaction-detail', extra: tx),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isReceive
                                    ? const Color(0xFF00F5A0).withOpacity(0.1)
                                    : const Color(0xFFB92BFF).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isReceive ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                color: isReceive ? const Color(0xFF00F5A0) : const Color(0xFFB92BFF),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tx.memo ?? (isReceive ? 'Claimed Drop' : 'Sent Drop'),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    timeStr,
                                    style: const TextStyle(color: Color(0xFF9E9EAF), fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${isReceive ? "+" : "-"}${tx.amountSats} sats',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: isReceive ? const Color(0xFF00F5A0) : Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: tx.status == TransactionStatus.success
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.amber.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    tx.status.name.toUpperCase(),
                                    style: TextStyle(
                                      color: tx.status == TransactionStatus.success ? Colors.green : Colors.amber,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
