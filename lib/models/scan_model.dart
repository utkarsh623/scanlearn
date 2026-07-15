import 'package:hive/hive.dart';

part 'scan_model.g.dart';

@HiveType(typeId: 0)
class ScanModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String userId;
  @HiveField(2)
  final String imageUrl;
  @HiveField(3)
  final String objectName;
  @HiveField(4)
  final String? category;
  @HiveField(5)
  final String? description;
  @HiveField(6)
  final List<String>? funFacts;
  @HiveField(7)
  final DateTime createdAt;

  ScanModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.objectName,
    this.category,
    this.description,
    this.funFacts,
    required this.createdAt,
  });

  factory ScanModel.fromJson(Map<String, dynamic> json) {
    return ScanModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      imageUrl: json['image_url'] as String,
      objectName: json['object_name'] as String,
      category: json['category'] as String?,
      description: json['description'] as String?,
      funFacts: (json['fun_facts'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'image_url': imageUrl,
      'object_name': objectName,
      'category': category,
      'description': description,
      'fun_facts': funFacts,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
