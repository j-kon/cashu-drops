import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/cdk/cdk_service_provider.dart';

class WalletSetupScreen extends ConsumerStatefulWidget {
  const WalletSetupScreen({super.key});

  @override
  ConsumerState<WalletSetupScreen> createState() => _WalletSetupScreenState();
}

class _WalletSetupScreenState extends ConsumerState<WalletSetupScreen> {
  final _restoreController = TextEditingController();
  bool _isRestoring = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _restoreController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateWallet() async {
    setState(() => _isLoading = true);
    try {
      final walletService = ref.read(cdkWalletServiceProvider);
      await walletService.createWallet();
      if (mounted) {
        context.go('/mint-setup');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create wallet: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRestoreWallet() async {
    final seed = _restoreController.text.trim();
    if (seed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your backup seed/phrase')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final walletService = ref.read(cdkWalletServiceProvider);
      await walletService.restoreWallet(seed);
      if (mounted) {
        context.go('/mint-setup');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to restore wallet: $e')),
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
        title: const Text('Setup Wallet'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Let\'s initialize your ecash vault.',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You can generate a brand new Cashu wallet or restore an existing one from a mnemonic backup phrase.',
                style: TextStyle(
                  color: Color(0xFF9E9EAF),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              if (!_isRestoring) ...[
                Card(
                  child: InkWell(
                    onTap: _isLoading ? null : _handleCreateWallet,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00F5A0).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_moderator_rounded,
                              color: Color(0xFF00F5A0),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Create New Wallet',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Generate a fresh local keypair',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9E9EAF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: InkWell(
                    onTap: () => setState(() => _isRestoring = true),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB92BFF).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.settings_backup_restore_rounded,
                              color: Color(0xFFB92BFF),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Restore Wallet',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Import an existing seed phrase',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9E9EAF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else ...[
                TextField(
                  controller: _restoreController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Enter Seed Phrase or Backup String',
                    hintText: 'e.g., word1 word2 word3...',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRestoreWallet,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : const Text('Restore Now'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _isLoading ? null : () => setState(() => _isRestoring = false),
                  child: const Text('Go Back'),
                ),
              ],
              const Spacer(),
              if (_isLoading && !_isRestoring)
                const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00F5A0)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
