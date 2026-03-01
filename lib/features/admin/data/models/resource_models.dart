import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resqnow_admin/features/admin/domain/entities/resource_entities.dart';

/// Category Model - Matches main app data structure
class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final String? iconAsset;
  final List<String> imageUrls;
  final String? videoUrl;
  final int? order;
  final List<String> aliases;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.iconAsset,
    List<String>? imageUrls,
    this.videoUrl,
    this.order,
    List<String>? aliases,
  }) : imageUrls = imageUrls ?? [],
       aliases = aliases ?? [];

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      iconPath: iconAsset,
      displayOrder: order ?? 999,
      isVisible: true,
      searchAliases: aliases,
      createdAt: DateTime.now(),
      updatedAt: null,
    );
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      iconAsset: json['iconAsset'] as String?,
      imageUrls: List<String>.from(json['imageUrls'] as List? ?? []),
      videoUrl: json['videoUrl'] as String?,
      order: json['order'] as int?,
      aliases: List<String>.from(json['aliases'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'iconAsset': iconAsset,
      'imageUrls': imageUrls,
      'videoUrl': videoUrl,
      'order': order ?? 999,
      'aliases': aliases,
      'isVisible': true,
    };
  }
}

/// Emergency Number Model - Matches main app data structure
class EmergencyNumberModel {
  final String id;
  final String name;
  final String number;

  EmergencyNumberModel({
    required this.id,
    required this.name,
    required this.number,
  });

  EmergencyNumberEntity toEntity() {
    return EmergencyNumberEntity(
      id: id,
      serviceName: name,
      phoneNumber: number,
      category: '',
      description: null,
      areaOfCoverage: null,
      operatingHours: null,
      priority: 1,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: null,
    );
  }

  factory EmergencyNumberModel.fromJson(Map<String, dynamic> json) {
    return EmergencyNumberModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      number: json['number'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'number': number};
  }
}

/// Resource Model
class ResourceModel {
  final String id;
  final String name;
  final String description;
  final List<String> categories;
  final List<String> tags;
  final List<String> imageUrls;
  final String? whenToUse;
  final String? safetyTips;
  final String? proTip;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ResourceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.categories,
    required this.tags,
    required this.imageUrls,
    this.whenToUse,
    this.safetyTips,
    this.proTip,
    required this.isFeatured,
    required this.createdAt,
    this.updatedAt,
  });

  ResourceEntity toEntity() {
    return ResourceEntity(
      id: id,
      name: name,
      description: description,
      categories: categories,
      tags: tags,
      imageUrls: imageUrls,
      whenToUse: whenToUse,
      safetyTips: safetyTips,
      proTip: proTip,
      isFeatured: isFeatured,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    // Helper function to convert Timestamp or String to DateTime
    DateTime parseDateTime(dynamic value) {
      if (value == null) {
        return DateTime.now();
      } else if (value is Timestamp) {
        return value.toDate();
      } else if (value is String && value.isNotEmpty) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return DateTime.now();
        }
      } else if (value is int) {
        // Handle unix timestamp in milliseconds or seconds
        try {
          if (value > 10000000000) {
            // Likely milliseconds
            return DateTime.fromMillisecondsSinceEpoch(value);
          } else {
            // Likely seconds
            return DateTime.fromMillisecondsSinceEpoch(value * 1000);
          }
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return ResourceModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      categories: List<String>.from(json['categories'] as List? ?? []),
      tags: List<String>.from(json['tags'] as List? ?? []),
      imageUrls: List<String>.from(json['imageUrls'] as List? ?? []),
      whenToUse: json['whenToUse'] as String?,
      safetyTips: json['safetyTips'] as String?,
      proTip: json['proTip'] as String?,
      isFeatured: json['isFeatured'] as bool? ?? false,
      createdAt: parseDateTime(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? parseDateTime(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'categories': categories,
      'tags': tags,
      'imageUrls': imageUrls,
      'whenToUse': whenToUse,
      'safetyTips': safetyTips,
      'proTip': proTip,
      'isFeatured': isFeatured,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

/// Medical Condition Model
class ConditionModel {
  final String id;
  final String name;
  final String severity;
  final List<String> imageUrls;
  final List<String> firstAidDescription;
  final List<String> doNotDo;
  final String? videoUrl;
  final List<Map<String, dynamic>> requiredKits;
  final List<Map<String, dynamic>> faqs;
  final List<String> doctorType;
  final String? hospitalLocatorLink;
  final List<String> categories;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ConditionModel({
    required this.id,
    required this.name,
    required this.severity,
    required this.imageUrls,
    required this.firstAidDescription,
    required this.doNotDo,
    this.videoUrl,
    required this.requiredKits,
    required this.faqs,
    required this.doctorType,
    this.hospitalLocatorLink,
    List<String>? categories,
    this.createdAt,
    this.updatedAt,
  }) : categories = categories ?? [];

  ConditionEntity toEntity() {
    return ConditionEntity(
      id: id,
      name: name,
      severity: severity,
      imageUrls: imageUrls,
      firstAidDescription: firstAidDescription,
      doNotDo: doNotDo,
      videoUrl: videoUrl,
      requiredKits: requiredKits,
      faqs: faqs,
      doctorType: doctorType,
      hospitalLocatorLink: hospitalLocatorLink,
      categories: categories,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt,
    );
  }

  factory ConditionModel.fromJson(Map<String, dynamic> json) {
    // Helper function to convert Timestamp or String to DateTime
    DateTime? parseDateTime(dynamic value) {
      if (value == null) {
        return null;
      } else if (value is Timestamp) {
        return value.toDate();
      } else if (value is String && value.isNotEmpty) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return null;
        }
      } else if (value is int) {
        try {
          if (value > 10000000000) {
            return DateTime.fromMillisecondsSinceEpoch(value);
          } else {
            return DateTime.fromMillisecondsSinceEpoch(value * 1000);
          }
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    try {
      print(
        '🔍 Deserializing condition: name=${json['name']}, severity=${json['severity']}',
      );

      // Safe list conversion for strings
      List<String> toStringList(dynamic value) {
        try {
          if (value == null) return [];
          if (value is List) {
            return value
                .map((e) => e.toString().trim())
                .where((e) => e.isNotEmpty)
                .toList();
          }
          return [];
        } catch (e) {
          print('⚠️ Error converting to string list: $e');
          return [];
        }
      }

      // Safe list conversion for maps
      List<Map<String, dynamic>> toMapList(dynamic value) {
        try {
          if (value == null) return [];
          if (value is List) {
            return value
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item as Map))
                .toList();
          }
          return [];
        } catch (e) {
          print('⚠️ Error converting to map list: $e');
          return [];
        }
      }

      return ConditionModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        severity: json['severity'] as String? ?? 'low',
        imageUrls: toStringList(json['imageUrls']),
        firstAidDescription: toStringList(
          json['firstAidDescription'] ?? json['firstAidSteps'],
        ),
        doNotDo: toStringList(json['doNotDo']),
        videoUrl: json['videoUrl'] as String?,
        requiredKits: toMapList(json['requiredKits']),
        faqs: toMapList(json['faqs']),
        doctorType: toStringList(json['doctorType'] ?? json['doctorTypes']),
        hospitalLocatorLink: json['hospitalLocatorLink'] as String?,
        categories: toStringList(json['categories']),
        createdAt: parseDateTime(json['createdAt']),
        updatedAt: json['updatedAt'] != null
            ? parseDateTime(json['updatedAt'])
            : null,
      );
    } catch (e, stackTrace) {
      print('❌ Error deserializing condition: $e');
      print('Data: $json');
      print('Stack: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'severity': severity,
      'imageUrls': imageUrls,
      'firstAidDescription': firstAidDescription,
      'doNotDo': doNotDo,
      'videoUrl': videoUrl,
      'requiredKits': requiredKits,
      'faqs': faqs,
      'doctorType': doctorType,
      'hospitalLocatorLink': hospitalLocatorLink,
      'categories': categories,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
