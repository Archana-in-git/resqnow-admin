import 'package:equatable/equatable.dart';

/// Category entity for admin management
class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String? iconPath;
  final int displayOrder;
  final bool isVisible;
  final List<String>? searchAliases;

  const CategoryEntity({
    required this.id,
    required this.name,
    this.iconPath,
    required this.displayOrder,
    required this.isVisible,
    this.searchAliases,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    iconPath,
    displayOrder,
    isVisible,
    searchAliases,
  ];
}

/// Emergency Number entity
class EmergencyNumberEntity extends Equatable {
  final String id;
  final String serviceName;
  final String phoneNumber;

  const EmergencyNumberEntity({
    required this.id,
    required this.serviceName,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [id, serviceName, phoneNumber];
}

/// First Aid Resource entity
class ResourceEntity extends Equatable {
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

  const ResourceEntity({
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

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    categories,
    tags,
    imageUrls,
    whenToUse,
    safetyTips,
    proTip,
    isFeatured,
    createdAt,
    updatedAt,
  ];
}

/// Medical Condition entity
class ConditionEntity extends Equatable {
  final String id;
  final String name;
  final String severity;
  final List<String> imageUrls;
  final List<String> firstAidDescription;
  final String? videoUrl;
  final List<Map<String, dynamic>> faqs;
  final List<String> doctorType;
  final String? hospitalLocatorLink;
  final List<String> categories;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ConditionEntity({
    required this.id,
    required this.name,
    required this.severity,
    required this.imageUrls,
    required this.firstAidDescription,
    this.videoUrl,
    required this.faqs,
    required this.doctorType,
    this.hospitalLocatorLink,
    List<String>? categories,
    required this.createdAt,
    this.updatedAt,
  }) : categories = categories ?? [];

  @override
  List<Object?> get props => [
    id,
    name,
    severity,
    imageUrls,
    firstAidDescription,
    videoUrl,
    faqs,
    doctorType,
    hospitalLocatorLink,
    categories,
    createdAt,
    updatedAt,
  ];
}

