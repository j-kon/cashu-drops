import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../storage/local_storage_service.dart';
import '../storage/secure_storage_service.dart';
import '../models/wallet_balance.dart';
import '../models/drop_transaction.dart';
import 'cdk_wallet_service.dart';
import 'mock_cdk_wallet_service.dart';
import 'real_cdk_wallet_service.dart';
import 'cdk_log.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStorageService(prefs);
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

class WalletServiceTypeNotifier extends StateNotifier<bool> {
  final LocalStorageService _storage;

  WalletServiceTypeNotifier(this._storage) : super(_storage.getUseMockWallet());

  Future<void> setUseMock(bool useMock) async {
    await _storage.setUseMockWallet(useMock);
    state = useMock;
  }
}

final useMockWalletProvider = StateNotifierProvider<WalletServiceTypeNotifier, bool>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return WalletServiceTypeNotifier(storage);
});

final cdkWalletServiceProvider = Provider<CdkWalletService>((ref) {
  final useMock = ref.watch(useMockWalletProvider);
  final localStorage = ref.watch(localStorageServiceProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  final logger = ref.watch(cdkLogProvider.notifier);

  if (useMock) {
    return MockCdkWalletService(
      localStorage: localStorage,
      secureStorage: secureStorage,
      logger: logger,
    );
  } else {
    return RealCdkWalletService(
      localStorage: localStorage,
      secureStorage: secureStorage,
      logger: logger,
    );
  }
});

class WalletState {
  final WalletBalance balance;
  final String activeMintUrl;
  final List<DropTransaction> transactions;
  final bool isLoading;

  WalletState({
    required this.balance,
    required this.activeMintUrl,
    required this.transactions,
    this.isLoading = false,
  });

  WalletState copyWith({
    WalletBalance? balance,
    String? activeMintUrl,
    List<DropTransaction>? transactions,
    bool? isLoading,
  }) {
    return WalletState(
      balance: balance ?? this.balance,
      activeMintUrl: activeMintUrl ?? this.activeMintUrl,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class WalletNotifier extends StateNotifier<WalletState> {
  final Ref _ref;

  WalletNotifier(this._ref)
      : super(WalletState(
          balance: WalletBalance.zero(),
          activeMintUrl: '',
          transactions: [],
        )) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    final wallet = _ref.read(cdkWalletServiceProvider);
    final storage = _ref.read(localStorageServiceProvider);
    
    try {
      final bal = await wallet.getBalance();
      final mint = storage.getActiveMintUrl() ?? 'https://testnut.cashu.space';
      final txs = await wallet.getTransactions();
      state = WalletState(
        balance: bal,
        activeMintUrl: mint,
        transactions: List.from(txs),
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final walletNotifierProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return WalletNotifier(ref);
});
