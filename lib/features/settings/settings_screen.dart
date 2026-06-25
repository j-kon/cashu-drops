import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/cdk/cdk_service_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useMock = ref.watch(useMockWalletProvider);
    final walletState = ref.watch(walletNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            Card(
              color: const Color(0xFFFF5252).withOpacity(0.08),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_rounded, color: Color(0xFFFF5252)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Developer Test Environment',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'CashuDrops is currently running in a test mode. Do not use mainnet mints or send substantial amounts of real Bitcoin. Ecash keys are saved locally on this device.',
                            style: TextStyle(color: Color(0xFF9E9EAF), fontSize: 11, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'NETWORK & CONNECTION',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF9E9EAF), letterSpacing: 1.2),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Active Mint URL', style: TextStyle(fontSize: 14)),
                    subtitle: Text(
                      walletState.activeMintUrl.isEmpty ? 'Not connected' : walletState.activeMintUrl,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/mint-setup'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'WALLET ENGINE CONFIG',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF9E9EAF), letterSpacing: 1.2),
            ),
            const SizedBox(height: 8),
            Card(
              child: SwitchListTile(
                title: const Text('Mock Wallet Mode', style: TextStyle(fontSize: 14)),
                subtitle: const Text('Uses dummy wallet and logs fake transactions.', style: TextStyle(fontSize: 11)),
                value: useMock,
                activeColor: const Color(0xFF00F5A0),
                onChanged: (value) async {
                  await ref.read(useMockWalletProvider.notifier).setUseMock(value);
                  ref.read(walletNotifierProvider.notifier).refresh();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Switched to ${value ? 'Mock Wallet' : 'Real CDK Wallet'} Engine')),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'SECURITY',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF9E9EAF), letterSpacing: 1.2),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.key_rounded, color: Color(0xFFB92BFF)),
                    title: const Text('Backup Mnemonic Phrase', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('Show seed recovery details', style: TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/backup'),
                  ),
                  const Divider(height: 1, color: Color(0xFF2C2F3E)),
                  ListTile(
                    leading: const Icon(Icons.delete_forever_rounded, color: Color(0xFFFF5252)),
                    title: const Text('Clear Storage & Reset', style: TextStyle(fontSize: 14, color: Color(0xFFFF5252))),
                    subtitle: const Text('Wipes local databases and secure wallet seed.', style: TextStyle(fontSize: 11)),
                    onTap: () => _confirmWipeStorage(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            const Center(
              child: Text(
                'CashuDrops • v0.1.0-alpha',
                style: TextStyle(fontSize: 12, color: Color(0xFF9E9EAF), fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Built with cdk-dart',
                style: TextStyle(fontSize: 10, color: Color(0xFF9E9EAF)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmWipeStorage(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Wallet?'),
        content: const Text(
          'This will permanently delete all local backups, credentials, and drops. Ensure you have backed up any ecash secrets. This action is irreversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF5252)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final local = ref.read(localStorageServiceProvider);
      final secure = ref.read(secureStorageServiceProvider);
      
      await local.clearAll();
      await secure.clearAll();
      
      ref.read(walletNotifierProvider.notifier).refresh();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wallet data wiped successfully')),
        );
        context.go('/');
      }
    }
  }
}
