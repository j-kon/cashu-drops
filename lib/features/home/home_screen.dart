import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/cdk/cdk_service_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletNotifierProvider);
    final useMock = ref.watch(useMockWalletProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF00F5A0),
          onRefresh: () => ref.read(walletNotifierProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF00F5A0), Color(0xFFB92BFF)],
                          ),
                        ),
                        child: const Icon(Icons.water_drop, color: Colors.black, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'CashuDrops',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  if (useMock)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9900).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFF9900).withOpacity(0.3)),
                      ),
                      child: const Text(
                        'MOCK WALLET',
                        style: TextStyle(
                          color: Color(0xFFFF9900),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00F5A0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF00F5A0).withOpacity(0.3)),
                      ),
                      child: const Text(
                        'REAL WALLET',
                        style: TextStyle(
                          color: Color(0xFF00F5A0),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1E212B),
                      const Color(0xFF161820).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: const Color(0xFF2C2F3E), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00F5A0).withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'TOTAL BALANCE',
                      style: TextStyle(
                        color: Color(0xFF9E9EAF),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${walletState.balance.balanceSats}',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'sats',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00F5A0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Color(0xFF2C2F3E), height: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'CONNECTED MINT',
                          style: TextStyle(fontSize: 10, color: Color(0xFF9E9EAF), fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Text(
                            walletState.activeMintUrl.isEmpty ? 'None' : walletState.activeMintUrl,
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5252).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFF5252).withOpacity(0.2)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.gpp_maybe_outlined, color: Color(0xFFFF5252), size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Demo wallet: use tiny amounts or test mints only.',
                        style: TextStyle(color: Color(0xFF9E9EAF), fontSize: 11, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/receive'),
                      icon: const Icon(Icons.arrow_downward_rounded, size: 20),
                      label: const Text('Receive Drop'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00F5A0),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/send'),
                      icon: const Icon(Icons.arrow_upward_rounded, size: 20),
                      label: const Text('Send Drop'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB92BFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildMenuItem(
                context: context,
                icon: Icons.history_rounded,
                title: 'Drop History',
                subtitle: 'View sent and received drops',
                color: const Color(0xFF00F5A0),
                onTap: () => context.push('/history'),
              ),
              const SizedBox(height: 12),
              _buildMenuItem(
                context: context,
                icon: Icons.terminal_rounded,
                title: 'Developer Console',
                subtitle: 'Inspect real-time CDK wallet logs',
                color: Colors.cyan,
                onTap: () => context.push('/developer-console'),
              ),
              const SizedBox(height: 12),
              _buildMenuItem(
                context: context,
                icon: Icons.settings_rounded,
                title: 'Settings & Backups',
                subtitle: 'Mints, security, mock mode toggles',
                color: const Color(0xFFB92BFF),
                onTap: () => context.push('/settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Color(0xFF9E9EAF), fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF9E9EAF)),
            ],
          ),
        ),
      ),
    );
  }
}
