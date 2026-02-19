import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resqnow_admin/features/admin/domain/entities/resource_entities.dart';

/// Category Model - Matches main app data structure
class CategoryModel {
  final String id;
  final String name;
  final String? iconAsset;
  final int? order;
  final List<String>? aliases;

  CategoryModel({
    required this.id,
    required this.name,
    this.iconAsset,
    this.order,
    this.aliases,
  });

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
      iconAsset: json['iconAsset'] as String?,
      order: json['order'] as int?,
      aliases: List<String>.from(json['aliases'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'iconAsset': iconAsset,
      'order': order ?? 999,
      'aliases': aliases ?? [],
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
    return {
      'name': name,
      'number': number,
    };
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
    DateTime _parseDateTime(dynamic value) {
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
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? _parseDateTime(json['updatedAt'])
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
  final List<String> firstAidSteps;
  final List<String> doNotDo;
  final String? videoUrl;
  final List<Map<String, String>> requiredKits;
  final List<Map<String, String>> faqs;
  final List<String> doctorTypes;
  final String? hospitalLocatorLink;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ConditionModel({
    required this.id,
    required this.name,
    required this.severity,
    required this.imageUrls,
    required this.firstAidSteps,
    required this.doNotDo,
    this.videoUrl,
    required this.requiredKits,
    required this.faqs,
    required this.doctorTypes,
    this.hospitalLocatorLink,
    required this.createdAt,
    this.updatedAt,
  });

  ConditionEntity toEntity() {
    return ConditionEntity(
      id: id,
      name: name,
      severity: severity,
      imageUrls: imageUrls,
      firstAidSteps: firstAidSteps,
      doNotDo: doNotDo,
      videoUrl: videoUrl,
      requiredKits: requiredKits,
      faqs: faqs,
      doctorTypes: doctorTypes,
      hospitalLocatorLink: hospitalLocatorLink,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ConditionModel.fromJson(Map<String, dynamic> json) {
    // Helper function to convert Timestamp or String to DateTime
    DateTime _parseDateTime(dynamic value) {
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

    return ConditionModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      severity: json['severity'] as String? ?? '',
      imageUrls: List<String>.from(json['imageUrls'] as List? ?? []),
      firstAidSteps: List<String>.from(json['firstAidSteps'] as List? ?? []),
      doNotDo: List<String>.from(json['doNotDo'] as List? ?? []),
      videoUrl: json['videoUrl'] as String?,
      requiredKits: List<Map<String, String>>.from(
        (json['requiredKits'] as List? ?? []).map(
          (item) => Map<String, String>.from(item as Map),
        ),
      ),
      faqs: List<Map<String, String>>.from(
        (json['faqs'] as List? ?? []).map(
          (item) => Map<String, String>.from(item as Map),
        ),
      ),
      doctorTypes: List<String>.from(json['doctorTypes'] as List? ?? []),
      hospitalLocatorLink: json['hospitalLocatorLink'] as String?,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? _parseDateTime(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'severity': severity,
      'imageUrls': imageUrls,
      'firstAidSteps': firstAidSteps,
      'doNotDo': doNotDo,
      'videoUrl': videoUrl,
      'requiredKits': requiredKits,
      'faqs': faqs,
      'doctorTypes': doctorTypes,
      'hospitalLocatorLink': hospitalLocatorLink,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
