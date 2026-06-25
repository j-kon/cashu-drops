import '../models/wallet_balance.dart';
import '../models/drop_transaction.dart';
import '../models/mint_info.dart';

abstract class CdkWalletService {
  Future<void> createWallet();
  Future<void> restoreWallet(String seedOrBackup);
  Future<void> addMint(String mintUrl);
  Future<MintInfo> getMintInfo();
  Future<WalletBalance> getBalance();
  Future<String> sendToken({required int amount, String? memo});
  Future<void> receiveToken(String token);
  Future<List<DropTransaction>> getTransactions();
  Future<void> requestMintQuote(int amount);
  Future<void> meltTokens(String lightningInvoice);
}
