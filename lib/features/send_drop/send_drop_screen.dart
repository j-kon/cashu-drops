import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/cdk/cdk_service_provider.dart';

class SendDropScreen extends ConsumerStatefulWidget {
  const SendDropScreen({super.key});

  @override
  ConsumerState<SendDropScreen> createState() => _SendDropScreenState();
}

class _SendDropScreenState extends ConsumerState<SendDropScreen> {
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final amountText = _amountController.text.trim();
    final amount = int.tryParse(amountText);
    
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount in satoshis')),
      );
      return;
    }

    final memo = _memoController.text.trim();

    setState(() => _isLoading = true);
    try {
      final walletService = ref.read(cdkWalletServiceProvider);
      final token = await walletService.sendToken(
        amount: amount,
        memo: memo.isEmpty ? null : memo,
      );
      
      ref.read(walletNotifierProvider.notifier).refresh();
      
      if (mounted) {
        context.pushReplacement('/qr-display', extra: token);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create drop: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Drop'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create a Cashu Drop',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter the amount of satoshis to lock into an ecash token drop. Anyone with the token can claim it.',
                style: TextStyle(color: Color(0xFF9E9EAF), fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (sats)',
                  hintText: 'e.g., 21',
                  prefixIcon: Icon(Icons.currency_bitcoin_rounded, color: Color(0xFF00F5A0)),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _memoController,
                decoration: const InputDecoration(
                  labelText: 'Memo (Optional)',
                  hintText: 'e.g., Coffee, gift, lunch...',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
                keyboardType: TextInputType.text,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSend,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB92BFF),
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Generate Drop Token'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
