import 'package:go_router/go_router.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/wallet_setup/wallet_setup_screen.dart';
import '../features/mint_setup/mint_setup_screen.dart';
import '../features/home/home_screen.dart';
import '../features/receive_drop/receive_drop_screen.dart';
import '../features/send_drop/send_drop_screen.dart';
import '../features/qr/qr_display_screen.dart';
import '../features/qr/qr_scanner_screen.dart';
import '../features/history/history_screen.dart';
import '../features/history/transaction_detail_screen.dart';
import '../features/developer_console/developer_console_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/backup_screen.dart';
import '../core/models/drop_transaction.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/wallet-setup',
      builder: (context, state) => const WalletSetupScreen(),
    ),
    GoRoute(
      path: '/mint-setup',
      builder: (context, state) => const MintSetupScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/receive',
      builder: (context, state) => const ReceiveDropScreen(),
    ),
    GoRoute(
      path: '/send',
      builder: (context, state) => const SendDropScreen(),
    ),
    GoRoute(
      path: '/qr-display',
      builder: (context, state) {
        final token = state.extra as String? ?? '';
        return QrDisplayScreen(token: token);
      },
    ),
    GoRoute(
      path: '/qr-scan',
      builder: (context, state) => const QrScannerScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/transaction-detail',
      builder: (context, state) {
        final tx = state.extra as DropTransaction;
        return TransactionDetailScreen(transaction: tx);
      },
    ),
    GoRoute(
      path: '/developer-console',
      builder: (context, state) => const DeveloperConsoleScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/backup',
      builder: (context, state) => const BackupScreen(),
    ),
  ],
);
