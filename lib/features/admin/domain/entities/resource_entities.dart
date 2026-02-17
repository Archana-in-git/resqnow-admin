import 'package:equatable/equatable.dart';

/// Category entity for admin management
class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String? iconPath;
  final int displayOrder;
  final bool isVisible;
  final List<String>? searchAliases;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CategoryEntity({
    required this.id,
    required this.name,
    this.iconPath,
    required this.displayOrder,
    required this.isVisible,
    this.searchAliases,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    iconPath,
    displayOrder,
    isVisible,
    searchAliases,
    createdAt,
    updatedAt,
  ];
}

/// Emergency Number entity
class EmergencyNumberEntity extends Equatable {
  final String id;
  final String serviceName;
  final String phoneNumber;
  final String category;
  final String? description;
  final String? areaOfCoverage;
  final String? operatingHours;
  final int priority;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const EmergencyNumberEntity({
    required this.id,
    required this.serviceName,
    required this.phoneNumber,
    required this.category,
    this.description,
    this.areaOfCoverage,
    this.operatingHours,
    required this.priority,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    serviceName,
    phoneNumber,
    category,
    description,
    areaOfCoverage,
    operatingHours,
    priority,
    isActive,
    createdAt,
    updatedAt,
  ];
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
  final List<String> firstAidSteps;
  final List<String> doNotDo;
  final String? videoUrl;
  final List<Map<String, String>> requiredKits;
  final List<Map<String, String>> faqs;
  final List<String> doctorTypes;
  final String? hospitalLocatorLink;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ConditionEntity({
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

  @override
  List<Object?> get props => [
    id,
    name,
    severity,
    imageUrls,
    firstAidSteps,
    doNotDo,
    videoUrl,
    requiredKits,
    faqs,
    doctorTypes,
    hospitalLocatorLink,
    createdAt,
    updatedAt,
  ];
}
