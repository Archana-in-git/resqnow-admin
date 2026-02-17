/// Enums and Constants for Admin Dashboard

enum UserRole { admin, user, support, moderator }

enum AccountStatus { active, suspended, deleted }

enum DonorStatus { available, unavailable, suspended }

enum ResourceCategory {
  emergencyCare,
  wounds,
  breathing,
  poisoning,
  burns,
  fractures,
  choking,
}

enum ConditionSeverity { low, medium, high, critical }

enum EmergencyServiceCategory {
  ambulance,
  police,
  fire,
  disasterManagement,
  medical,
  other,
}

class AdminConstants {
  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;

  // Validation
  static const int minNameLength = 3;
  static const int maxNameLength = 100;
  static const int minDescriptionLength = 10;
  static const int maxDescriptionLength = 2000;

  // Blood groups
  static const List<String> bloodGroups = [
    'O+',
    'O-',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
  ];

  // Medical conditions
  static const List<String> medicalConditions = [
    'Diabetes',
    'Blood Pressure',
    'Thyroid',
    'Asthma',
    'Heart Disease',
    'None',
  ];

  // Emergency categories
  static const List<String> emergencyCategories = [
    'Ambulance',
    'Police',
    'Fire',
    'Disaster Management',
    'Medical',
    'Other',
  ];

  // Default values
  static const String defaultImageUrl = 'https://via.placeholder.com/200';
  static const int defaultDisplayOrder = 999;
  static const bool defaultVisibility = true;
}
