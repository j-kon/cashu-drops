import 'dart:async';
import 'dart:io';
import 'package:cdk/cdk.dart' hide MintInfo;
import '../models/wallet_balance.dart';
import '../models/drop_transaction.dart';
import '../models/mint_connection.dart';
import '../models/mint_info.dart';
import '../storage/local_storage_service.dart';
import '../storage/secure_storage_service.dart';
import 'cdk_wallet_service.dart';
import 'cdk_log.dart';

class RealCdkWalletService implements CdkWalletService {
  final LocalStorageService _localStorage;
  final SecureStorageService _secureStorage;
  final CdkLogNotifier _logger;

  Wallet? _wallet;

  RealCdkWalletService({
    required LocalStorageService localStorage,
    required SecureStorageService secureStorage,
    required CdkLogNotifier logger,
  })  : _localStorage = localStorage,
        _secureStorage = secureStorage,
        _logger = logger;

  Future<Wallet> _getOrInitWallet() async {
    if (_wallet != null) return _wallet!;

    final mnemonic = await _secureStorage.getMnemonic();
    if (mnemonic == null || mnemonic.isEmpty) {
      throw Exception('Wallet not initialized. Create or restore a wallet first.');
    }

    final activeMint = _localStorage.getActiveMintUrl() ?? 'https://testnut.cashu.space';
    final dbPath = '${Directory.systemTemp.path}/cashudrops_wallet.sqlite';

    _wallet = Wallet(
      mintUrl: activeMint,
      unit: SatCurrencyUnit(),
      mnemonic: mnemonic,
      store: SqliteWalletStore(dbPath),
      config: WalletConfig(targetProofCount: null),
    );

    return _wallet!;
  }

  @override
  Future<void> createWallet() async {
    _logger.log('createWallet', 'PENDING', 'Real CDK: Generating new wallet mnemonic...');
    try {
      final mnemonic = generateMnemonic();
      await _secureStorage.saveMnemonic(mnemonic);
      
      // Reset current wallet instance so it gets recreated with the new mnemonic
      if (_wallet != null) {
        _wallet!.dispose();
        _wallet = null;
      }
      
      _logger.log('createWallet', 'SUCCESS', 'Real CDK: Wallet created successfully.');
    } catch (e) {
      _logger.log('createWallet', 'ERROR', 'Real CDK: Failed to create wallet: $e');
      rethrow;
    }
  }

  @override
  Future<void> restoreWallet(String seedOrBackup) async {
    _logger.log('restoreWallet', 'PENDING', 'Real CDK: Restoring wallet from seed/backup...');
    try {
      final trimmed = seedOrBackup.trim();
      if (trimmed.isEmpty) {
        throw Exception('Mnemonic or backup phrase cannot be empty');
      }
      
      await _secureStorage.saveMnemonic(trimmed);
      
      // Reset current wallet instance so it gets recreated with the restored mnemonic
      if (_wallet != null) {
        _wallet!.dispose();
        _wallet = null;
      }
      
      _logger.log('restoreWallet', 'SUCCESS', 'Real CDK: Wallet restored successfully.');
    } catch (e) {
      _logger.log('restoreWallet', 'ERROR', 'Real CDK: Failed to restore wallet: $e');
      rethrow;
    }
  }

  @override
  Future<void> addMint(String mintUrl) async {
    _logger.log('addMint', 'PENDING', 'Real CDK: Adding mint $mintUrl...');
    try {
      final trimmedUrl = mintUrl.trim();
      if (!trimmedUrl.startsWith('http://') && !trimmedUrl.startsWith('https://')) {
        throw Exception('Invalid URL scheme: $trimmedUrl');
      }

      // Dispose the old wallet instance so it gets recreated with the new mint url
      if (_wallet != null) {
        _wallet!.dispose();
        _wallet = null;
      }

      await _localStorage.setActiveMintUrl(trimmedUrl);

      // Save to known mints list
      final known = _localStorage.getKnownMints();
      if (!known.any((m) => m.url == trimmedUrl)) {
        known.add(MintConnection(url: trimmedUrl, isConnected: true));
        await _localStorage.saveKnownMints(known);
      }

      // Reinitialize the wallet with the new mint to verify it compiles and connects
      final wallet = await _getOrInitWallet();
      await wallet.loadMintKeysets();

      _logger.log('addMint', 'SUCCESS', 'Real CDK: Connected to mint $trimmedUrl');
    } catch (e) {
      _logger.log('addMint', 'ERROR', 'Real CDK: Failed to connect to mint: $e');
      rethrow;
    }
  }

  @override
  Future<MintInfo> getMintInfo() async {
    final activeMint = _localStorage.getActiveMintUrl() ?? 'https://testnut.cashu.space';
    _logger.log('getMintInfo', 'PENDING', 'Real CDK: Requesting mint info from $activeMint...');
    try {
      final wallet = await _getOrInitWallet();
      final rawInfo = await wallet.loadMintInfo();

      final info = MintInfo(
        url: activeMint,
        name: rawInfo.name ?? 'Unknown Mint',
        version: rawInfo.version?.version ?? 'Unknown Version',
        description: rawInfo.description ?? '',
        pubkey: rawInfo.pubkey ?? '',
      );

      _logger.log('getMintInfo', 'SUCCESS', 'Real CDK: Retrieved mint info',
          rawResponseOrError: '{"name": "${info.name}", "version": "${info.version}", "pubkey": "${info.pubkey}"}');
      return info;
    } catch (e) {
      _logger.log('getMintInfo', 'ERROR', 'Real CDK: Failed to get mint info: $e');
      rethrow;
    }
  }

  @override
  Future<WalletBalance> getBalance() async {
    final mnemonic = await _secureStorage.getMnemonic();
    if (mnemonic == null || mnemonic.isEmpty) {
      return const WalletBalance(balanceSats: 0);
    }
    
    try {
      final wallet = await _getOrInitWallet();
      final balance = await wallet.totalBalance();
      return WalletBalance(balanceSats: balance.value);
    } catch (e) {
      _logger.log('getBalance', 'ERROR', 'Real CDK: Failed to retrieve balance: $e');
      return const WalletBalance(balanceSats: 0);
    }
  }

  Future<void> _saveTransaction({
    required int amount,
    required TransactionType type,
    required String? memo,
    required String? rawToken,
    required String? rawDebugInfo,
  }) async {
    final activeMint = _localStorage.getActiveMintUrl() ?? 'https://testnut.cashu.space';
    final transactions = _localStorage.getTransactions();
    final newTx = DropTransaction(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      amountSats: amount,
      type: type,
      timestamp: DateTime.now(),
      status: TransactionStatus.success,
      mintUrl: activeMint,
      memo: memo,
      rawToken: rawToken,
      rawDebugInfo: rawDebugInfo,
    );
    transactions.add(newTx);
    await _localStorage.saveTransactions(transactions);
  }

  @override
  Future<String> sendToken({required int amount, String? memo}) async {
    _logger.log('sendToken', 'PENDING', 'Real CDK: Constructing send transaction for $amount sats...');
    try {
      final wallet = await _getOrInitWallet();
      
      final sendMemo = memo != null ? SendMemo(memo: memo, includeMemo: true) : null;
      final sendOptions = SendOptions(
        memo: sendMemo,
        conditions: null,
        amountSplitTarget: NoneSplitTarget(),
        sendKind: OnlineExactSendKind(),
        includeFee: false,
        useP2bk: false,
        maxProofs: null,
        metadata: {},
        p2pkSigningKeys: [],
        p2pkLockedProofSendMode: P2pkLockedProofSendMode.swap,
      );
      
      final preparedSend = await wallet.prepareSend(
        amount: Amount(value: amount),
        options: sendOptions,
      );
      
      final token = await preparedSend.confirm(memo: memo);
      final encodedToken = token.encode();
      
      await _saveTransaction(
        amount: amount,
        type: TransactionType.send,
        memo: memo,
        rawToken: encodedToken,
        rawDebugInfo: '{"status": "success", "amount": $amount, "operationId": "${preparedSend.operationId()}"}',
      );
      
      _logger.log('sendToken', 'SUCCESS', 'Real CDK: Token generated successfully',
          rawResponseOrError: '{"token": "$encodedToken", "amount": $amount, "memo": "$memo"}');
      return encodedToken;
    } catch (e) {
      _logger.log('sendToken', 'ERROR', 'Real CDK: Failed to send token: $e');
      rethrow;
    }
  }

  @override
  Future<void> receiveToken(String token) async {
    final trimmed = token.trim();
    _logger.log('receiveToken', 'PENDING', 'Real CDK: Redeeming/claiming token: ${trimmed.substring(0, trimmed.length > 20 ? 20 : trimmed.length)}...');
    
    if (!trimmed.startsWith('cashu')) {
      final errMsg = 'Invalid token format. Must start with "cashu"';
      _logger.log('receiveToken', 'ERROR', 'Real CDK: $errMsg');
      throw Exception(errMsg);
    }
    
    try {
      final wallet = await _getOrInitWallet();
      
      _logger.log('receiveToken', 'PENDING', 'Real CDK: Decoding token...');
      final tokenObj = Token.decode(encodedToken: trimmed);
      
      final mintUrl = tokenObj.mintUrl().url;
      final amount = tokenObj.value().value;
      _logger.log('receiveToken', 'PENDING', 'Real CDK: Decoded token info: $amount sats from mint $mintUrl');
      
      final receiveOptions = ReceiveOptions(
        amountSplitTarget: NoneSplitTarget(),
        p2pkSigningKeys: [],
        preimages: [],
        metadata: {},
      );
      
      _logger.log('receiveToken', 'PENDING', 'Real CDK: Submitting token redemption request to mint...');
      final receivedAmount = await wallet.receive(
        token: tokenObj,
        options: receiveOptions,
      );
      
      final memo = tokenObj.memo();
      
      await _saveTransaction(
        amount: receivedAmount.value,
        type: TransactionType.receive,
        memo: memo,
        rawToken: trimmed,
        rawDebugInfo: '{"status": "success", "amount": ${receivedAmount.value}, "mint": "$mintUrl"}',
      );
      
      _logger.log('receiveToken', 'SUCCESS', 'Real CDK: Token redeemed successfully. Received ${receivedAmount.value} sats.',
          rawResponseOrError: '{"amount": ${receivedAmount.value}, "mint": "$mintUrl"}');
    } catch (e) {
      final errorStr = e.toString();
      String category = 'Unknown Error';
      if (errorStr.contains('TokenAlreadySpent') || errorStr.contains('spent') || errorStr.contains('already claimed')) {
        category = 'Token Already Spent / Claimed';
      } else if (errorStr.contains('HostLookup') || errorStr.contains('SocketException') || errorStr.contains('HttpException')) {
        category = 'Network Error / Mint Inaccessible';
      } else if (errorStr.contains('decode') || errorStr.contains('format')) {
        category = 'Token Decoding Error';
      }
      
      _logger.log('receiveToken', 'ERROR', 'Real CDK: Failed to receive token ($category): $errorStr');
      rethrow;
    }
  }

  @override
  Future<List<DropTransaction>> getTransactions() async {
    return _localStorage.getTransactions();
  }

  @override
  Future<void> requestMintQuote(int amount) async {
    final activeMint = _localStorage.getActiveMintUrl() ?? 'https://testnut.cashu.space';
    _logger.log('requestMintQuote', 'PENDING', 'Real CDK: Requesting mint quote for $amount sats from $activeMint...');
    try {
      final wallet = await _getOrInitWallet();
      final quote = await wallet.mintQuote(
        paymentMethod: Bolt11PaymentMethod(),
        amount: Amount(value: amount),
        description: null,
        extra: null,
      );
      
      _logger.log('requestMintQuote', 'SUCCESS', 'Real CDK: Mint quote requested successfully.',
          rawResponseOrError: '{"quote": "${quote.id}", "amount": $amount, "invoice": "${quote.request}"}');
    } catch (e) {
      _logger.log('requestMintQuote', 'ERROR', 'Real CDK: Failed to request mint quote: $e');
      rethrow;
    }
  }

  @override
  Future<void> meltTokens(String lightningInvoice) async {
    _logger.log('meltTokens', 'PENDING', 'Real CDK: Requesting token melt to pay $lightningInvoice...');
    try {
      final wallet = await _getOrInitWallet();
      
      final quote = await wallet.meltQuote(
        method: Bolt11PaymentMethod(),
        request: lightningInvoice,
        options: null,
        extra: null,
      );
      
      final preparedMelt = await wallet.prepareMelt(quoteId: quote.id);
      final finalizedMelt = await preparedMelt.confirm();
      
      if (finalizedMelt.state == QuoteState.paid) {
        final amountPaid = finalizedMelt.amount.value;
        final feePaid = finalizedMelt.feePaid.value;
        final totalPaid = amountPaid + feePaid;
        
        await _saveTransaction(
          amount: totalPaid,
          type: TransactionType.send,
          memo: 'Melt/Payment for Bolt11 Invoice',
          rawToken: null,
          rawDebugInfo: '{"status": "success", "quoteId": "${quote.id}", "preimage": "${finalizedMelt.preimage}"}',
        );
        
        _logger.log('meltTokens', 'SUCCESS', 'Real CDK: Tokens melted successfully.',
            rawResponseOrError: '{"preimage": "${finalizedMelt.preimage}", "amount": $amountPaid, "fee": $feePaid}');
      } else {
        throw Exception('Melt not paid. Final state: ${finalizedMelt.state}');
      }
    } catch (e) {
      _logger.log('meltTokens', 'ERROR', 'Real CDK: Failed to melt tokens: $e');
      rethrow;
    }
  }
}
