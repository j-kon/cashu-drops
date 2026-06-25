class MintInfo {
  final String url;
  final String name;
  final String version;
  final String description;
  final String pubkey;

  const MintInfo({
    required this.url,
    required this.name,
    required this.version,
    required this.description,
    required this.pubkey,
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'name': name,
      'version': version,
      'description': description,
      'pubkey': pubkey,
    };
  }

  factory MintInfo.fromJson(Map<String, dynamic> json) {
    return MintInfo(
      url: json['url'] as String,
      name: json['name'] as String,
      version: json['version'] as String,
      description: json['description'] as String,
      pubkey: json['pubkey'] as String,
    );
  }
}
