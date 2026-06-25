class WalletBalance {
  final int balanceSats;

  const WalletBalance({required this.balanceSats});

  factory WalletBalance.zero() => const WalletBalance(balanceSats: 0);

  @override
  String toString() => '$balanceSats sats';
}
