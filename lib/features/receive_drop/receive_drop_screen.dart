import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/cdk/cdk_service_provider.dart';

class ReceiveDropScreen extends ConsumerStatefulWidget {
  const ReceiveDropScreen({super.key});

  @override
  ConsumerState<ReceiveDropScreen> createState() => _ReceiveDropScreenState();
}

class _ReceiveDropScreenState extends ConsumerState<ReceiveDropScreen> {
  final _tokenController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _handleReceive() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please paste a Cashu token')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final walletService = ref.read(cdkWalletServiceProvider);
      await walletService.receiveToken(token);
      
      ref.read(walletNotifierProvider.notifier).refresh();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully claimed ecash drop!'),
            backgroundColor: Color(0xFF00F5A0),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to claim drop: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _scanQrCode() async {
    final result = await context.push<String>('/qr-scan');
    if (result != null && mounted) {
      _tokenController.text = result;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receive Drop'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Claim Cashu Token',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Paste a cashu token string or scan a QR code to redeem satoshis to your wallet.',
                style: TextStyle(color: Color(0xFF9E9EAF), fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _tokenController,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: 'Cashu Token',
                  hintText: 'cashuAeyJ...',
                  alignLabelWithHint: true,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF00F5A0)),
                    onPressed: _scanQrCode,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleReceive,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00F5A0),
                  foregroundColor: Colors.black,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Text('Claim Drop'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _scanQrCode,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Scan QR Code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
