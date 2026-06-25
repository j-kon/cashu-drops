import 'dart:async';
import '../models/wallet_balance.dart';
import '../models/drop_transaction.dart';
import '../models/mint_connection.dart';
import '../models/mint_info.dart';
import '../storage/local_storage_service.dart';
import '../storage/secure_storage_service.dart';
import 'cdk_wallet_service.dart';
import 'cdk_log.dart';

class MockCdkWalletService implements CdkWalletService {
  final LocalStorageService _localStorage;
  final SecureStorageService _secureStorage;
  final CdkLogNotifier _logger;

  int _balanceSats = 1000;
  String _activeMintUrl = 'https://testnut.cashu.space';
  final List<DropTransaction> _transactions = [];

  MockCdkWalletService({
    required LocalStorageService localStorage,
    required SecureStorageService secureStorage,
    required CdkLogNotifier logger,
  })  : _localStorage = localStorage,
        _secureStorage = secureStorage,
        _logger = logger {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    _activeMintUrl = _localStorage.getActiveMintUrl() ?? 'https://testnut.cashu.space';
    _transactions.addAll(_localStorage.getTransactions());
    if (_transactions.isEmpty) {
      _transactions.addAll([
        DropTransaction(
          id: 'mock-tx-1',
          amountSats: 50,
          type: TransactionType.receive,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          status: TransactionStatus.success,
          mintUrl: _activeMintUrl,
          memo: 'Welcome bonus drop',
          rawToken: 'cashuAeyJ0b2tlbiI6W3sibWludCI6Imh0dHBzOi8vdGVzdG51dC5jYXNodS5zcGFjZSIsImRjcmV5cyI6W119XX0=',
          rawDebugInfo: '{"status": "mocked", "event": "WelcomeDrop", "amount": 50}',
        ),
        DropTransaction(
          id: 'mock-tx-2',
          amountSats: 21,
          type: TransactionType.send,
          timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
          status: TransactionStatus.success,
          mintUrl: _activeMintUrl,
          memo: 'Coffee share',
          rawToken: 'cashuAeyJ0b2tlbiI6W3sibWludCI6Imh0dHBzOi8vdGVzdG51dC5jYXNodS5zcGFjZSIsImRjcmV5cyI6W119XX0=',
          rawDebugInfo: '{"status": "mocked", "event": "CoffeeSend", "amount": 21}',
        ),
      ]);
      _localStorage.saveTransactions(_transactions);
    }
    _recalculateBalance();
  }

  void _recalculateBalance() {
    int bal = 1000;
    for (var tx in _transactions) {
      if (tx.status == TransactionStatus.success) {
        if (tx.type == TransactionType.receive) {
          bal += tx.amountSats;
        } else {
          bal -= tx.amountSats;
        }
      }
    }
    _balanceSats = bal >= 0 ? bal : 0;
  }

  @override
  Future<void> createWallet() async {
    _logger.log('createWallet', 'PENDING', 'Generating new wallet mnemonic...');
    await Future.delayed(const Duration(seconds: 1));
    const mockMnemonic = 'mock seed phrase for cashu drops test wallet only';
    await _secureStorage.saveMnemonic(mockMnemonic);
    _logger.log(
      'createWallet',
      'SUCCESS',
      'Wallet created successfully. Mnemonic stored securely.',
      rawResponseOrError: '{"mnemonic": "$mockMnemonic"}',
    );
  }

  @override
  Future<void> restoreWallet(String seedOrBackup) async {
    _logger.log('restoreWallet', 'PENDING', 'Restoring wallet from seed/backup...');
    await Future.delayed(const Duration(seconds: 1));
    if (seedOrBackup.trim().isEmpty) {
      _logger.log('restoreWallet', 'ERROR', 'Mnemonic/Backup cannot be empty');
      throw Exception('Empty seed or backup');
    }
    await _secureStorage.saveMnemonic(seedOrBackup);
    _logger.log(
      'restoreWallet',
      'SUCCESS',
      'Wallet restored successfully.',
      rawResponseOrError: '{"input": "$seedOrBackup", "status": "restored"}',
    );
  }

  @override
  Future<void> addMint(String mintUrl) async {
    _logger.log('addMint', 'PENDING', 'Connecting to mint: $mintUrl');
    await Future.delayed(const Duration(seconds: 1));
    if (!mintUrl.startsWith('http://') && !mintUrl.startsWith('https://')) {
      _logger.log('addMint', 'ERROR', 'Invalid mint URL format: $mintUrl');
      throw Exception('Invalid URL');
    }
    _activeMintUrl = mintUrl;
    await _localStorage.setActiveMintUrl(mintUrl);
    
    final known = _localStorage.getKnownMints();
    if (!known.any((m) => m.url == mintUrl)) {
      known.add(MintConnection(url: mintUrl, isConnected: true));
      await _localStorage.saveKnownMints(known);
    }

    _logger.log(
      'addMint',
      'SUCCESS',
      'Successfully connected to mint: $mintUrl',
      rawResponseOrError: '{"mintUrl": "$mintUrl", "keysets": ["009a63f98c0800d9"]}',
    );
  }

  @override
  Future<MintInfo> getMintInfo() async {
    _logger.log('getMintInfo', 'PENDING', 'Fetching mint info from $_activeMintUrl');
    await Future.delayed(const Duration(milliseconds: 500));
    final mockInfo = MintInfo(
      url: _activeMintUrl,
      name: _activeMintUrl.contains('testnut') ? 'Testnut Mint' : 'Mock Cashu Mint',
      version: 'cdk-dart-mock-0.1.0',
      description: 'A mock Cashu mint for testing CashuDrops wallet.',
      pubkey: '02d84742918bb122709e3a6c5188f114674ffcf458f3fb8f480397034c8d197607',
    );
    _logger.log(
      'getMintInfo',
      'SUCCESS',
      'Retrieved mint info successfully',
      rawResponseOrError: '{"name": "${mockInfo.name}", "version": "${mockInfo.version}", "pubkey": "${mockInfo.pubkey}"}',
    );
    return mockInfo;
  }

  @override
  Future<WalletBalance> getBalance() async {
    _recalculateBalance();
    return WalletBalance(balanceSats: _balanceSats);
  }

  @override
  Future<String> sendToken({required int amount, String? memo}) async {
    _logger.log('sendToken', 'PENDING', 'Creating a drop for $amount sats...');
    await Future.delayed(const Duration(seconds: 1));
    _recalculateBalance();
    if (amount > _balanceSats) {
      _logger.log('sendToken', 'ERROR', 'Insufficient balance. Have $_balanceSats sats, need $amount sats.');
      throw Exception('Insufficient balance');
    }

    final String mockToken = 'cashuAeyJ0b2tlbiI6W3sibWludCI6IiRfYWN0aXZlTWludFVybCIsInByb29mcyI6W3siYW1vdW50Ijo2NCwic2VjcmV0IjoibW9jay1zZWNyZXQtMSIsIkMiOiJtb2NrLUMtMSIsImlkIjoiMDBjYXNodSJ9XX1dfQ==';
    
    final tx = DropTransaction(
      id: 'mock-tx-${DateTime.now().millisecondsSinceEpoch}',
      amountSats: amount,
      type: TransactionType.send,
      timestamp: DateTime.now(),
      status: TransactionStatus.success,
      mintUrl: _activeMintUrl,
      memo: memo,
      rawToken: mockToken,
      rawDebugInfo: '{"status": "success", "amount": $amount, "token": "$mockToken"}',
    );

    _transactions.add(tx);
    await _localStorage.saveTransactions(_transactions);
    _recalculateBalance();

    _logger.log(
      'sendToken',
      'SUCCESS',
      'Successfully created drop of $amount sats.',
      rawResponseOrError: '{"token": "$mockToken", "amount": $amount, "memo": "$memo"}',
    );

    return mockToken;
  }

  @override
  Future<void> receiveToken(String token) async {
    _logger.log('receiveToken', 'PENDING', 'Receiving drop token...');
    await Future.delayed(const Duration(seconds: 1));
    
    if (!token.startsWith('cashu')) {
      _logger.log('receiveToken', 'ERROR', 'Invalid Cashu token prefix. Must start with "cashu"');
      throw Exception('Invalid token prefix');
    }

    final amount = 42;
    
    final tx = DropTransaction(
      id: 'mock-tx-${DateTime.now().millisecondsSinceEpoch}',
      amountSats: amount,
      type: TransactionType.receive,
      timestamp: DateTime.now(),
      status: TransactionStatus.success,
      mintUrl: _activeMintUrl,
      memo: 'Received drop via QR/Paste',
      rawToken: token,
      rawDebugInfo: '{"status": "success", "amount": $amount, "action": "receive"}',
    );

    _transactions.add(tx);
    await _localStorage.saveTransactions(_transactions);
    _recalculateBalance();

    _logger.log(
      'receiveToken',
      'SUCCESS',
      'Successfully claimed drop of $amount sats!',
      rawResponseOrError: '{"amount": $amount, "mint": "$_activeMintUrl"}',
    );
  }

  @override
  Future<List<DropTransaction>> getTransactions() async {
    return _transactions;
  }

  @override
  Future<void> requestMintQuote(int amount) async {
    _logger.log('requestMintQuote', 'PENDING', 'Requesting quote for $amount sats from $_activeMintUrl...');
    await Future.delayed(const Duration(seconds: 1));
    
    _logger.log(
      'requestMintQuote',
      'SUCCESS',
      'Received mint quote request response',
      rawResponseOrError: '{"quote": "mock-quote-id-12345", "amount": $amount, "invoice": "lnbc1mockinvoice..."}',
    );
  }

  @override
  Future<void> meltTokens(String lightningInvoice) async {
    _logger.log('meltTokens', 'PENDING', 'Melting tokens to pay invoice: $lightningInvoice');
    await Future.delayed(const Duration(seconds: 1));
    
    _logger.log(
      'meltTokens',
      'SUCCESS',
      'Invoice paid successfully',
      rawResponseOrError: '{"payment_preimage": "mock-preimage-54321", "fee": 1}',
    );
  }
}
