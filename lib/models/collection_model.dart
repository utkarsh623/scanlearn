class CollectionModel {
  final String id;
  final String userId;
  final String name;
  final DateTime createdAt;

  CollectionModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
