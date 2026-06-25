import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/cdk/cdk_service_provider.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  String? _mnemonic;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMnemonic();
  }

  Future<void> _loadMnemonic() async {
    final secureStorage = ref.read(secureStorageServiceProvider);
    final mnemonic = await secureStorage.getMnemonic();
    setState(() {
      _mnemonic = mnemonic;
      _isLoading = false;
    });
  }

  void _copyToClipboard(BuildContext context) {
    if (_mnemonic != null) {
      Clipboard.setData(ClipboardData(text: _mnemonic!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backup mnemonic copied to clipboard!'),
          backgroundColor: Color(0xFF00F5A0),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet Backup'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Protect your backup phrase',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'This 12-word recovery mnemonic represents ownership of your Cashu ecash signatures. Write it down and keep it safe offline.',
                style: TextStyle(color: Color(0xFF9E9EAF), fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: Color(0xFF00F5A0)))
              else if (_mnemonic == null || _mnemonic!.isEmpty)
                Center(
                  child: Column(
                    children: const [
                      Icon(Icons.warning_amber_rounded, size: 48, color: Colors.amber),
                      SizedBox(height: 16),
                      Text(
                        'No mnemonic generated yet.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Try creating or restoring a wallet first.',
                        style: TextStyle(color: Color(0xFF9E9EAF), fontSize: 13),
                      ),
                    ],
                  ),
                )
              else ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: _mnemonic!
                              .split(' ')
                              .asMap()
                              .map((index, word) => MapEntry(
                                    index,
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF161820),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: const Color(0xFF2C2F3E)),
                                      ),
                                      child: Text(
                                        '${index + 1}. $word',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                  ))
                              .values
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: Color(0xFF2C2F3E)),
                        const SizedBox(height: 12),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, color: Color(0xFF00F5A0)),
                          onPressed: () => _copyToClipboard(context),
                          tooltip: 'Copy Backup Mnemonic',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00F5A0),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('I Have Stored It Safely'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
