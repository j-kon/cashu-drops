class MintConnection {
  final String url;
  final bool isConnected;
  final String? nickname;

  const MintConnection({
    required this.url,
    required this.isConnected,
    this.nickname,
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'isConnected': isConnected,
      'nickname': nickname,
    };
  }

  factory MintConnection.fromJson(Map<String, dynamic> json) {
    return MintConnection(
      url: json['url'] as String,
      isConnected: json['isConnected'] as bool,
      nickname: json['nickname'] as String?,
    );
  }
}
