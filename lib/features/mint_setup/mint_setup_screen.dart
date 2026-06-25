import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/cdk/cdk_service_provider.dart';

class MintSetupScreen extends ConsumerStatefulWidget {
  const MintSetupScreen({super.key});

  @override
  ConsumerState<MintSetupScreen> createState() => _MintSetupScreenState();
}

class _MintSetupScreenState extends ConsumerState<MintSetupScreen> {
  final _mintController = TextEditingController(text: 'https://testnut.cashu.space');
  bool _isLoading = false;

  @override
  void dispose() {
    _mintController.dispose();
    super.dispose();
  }

  Future<void> _handleConnectMint() async {
    final mintUrl = _mintController.text.trim();
    if (mintUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a mint URL')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final walletService = ref.read(cdkWalletServiceProvider);
      await walletService.addMint(mintUrl);
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect to mint: $e')),
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
        title: const Text('Connect Mint'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Connect to a Cashu Mint',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ecash tokens are backed by funds held in trust by Cashu mints. Connect to a test mint to get started.',
                style: TextStyle(
                  color: Color(0xFF9E9EAF),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _mintController,
                decoration: const InputDecoration(
                  labelText: 'Mint Endpoint URL',
                  hintText: 'https://...',
                  prefixIcon: Icon(Icons.lan_outlined),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              const Text(
                'Recommended test mints:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF9E9EAF)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    label: const Text('testnut.cashu.space'),
                    onPressed: () {
                      _mintController.text = 'https://testnut.cashu.space';
                    },
                  ),
                  ActionChip(
                    label: const Text('legend.lnbits.com/cashu/...'),
                    onPressed: () {
                      _mintController.text = 'https://legend.lnbits.com/cashu/api/v1/4TsgP1E5h42XvQWc5p6H6S';
                    },
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleConnectMint,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Text('Connect & Enter Wallet'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
