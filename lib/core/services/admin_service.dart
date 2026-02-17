import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resqnow_admin/features/admin/data/models/admin_user_model.dart';
import 'package:resqnow_admin/features/admin/data/models/blood_donor_model.dart';
import 'package:resqnow_admin/features/admin/data/models/resource_models.dart';

/// Core Admin Service for Firestore operations
class AdminService {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  static const String usersCollection = 'users';
  static const String bloodDonorsCollection = 'blood_donors';
  static const String categoriesCollection = 'categories';
  static const String emergencyNumbersCollection = 'emergency_numbers';
  static const String resourcesCollection = 'resources';
  static const String conditionsCollection = 'conditions';

  AdminService({required this.firestore, required this.auth});

  /// ============ User Management ============

  /// Get all users
  Future<List<AdminUserModel>> getAllUsers({
    int limit = 10,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = firestore.collection(usersCollection).limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map(
            (doc) => AdminUserModel.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'uid': doc.id,
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  /// Search users by email
  Future<List<AdminUserModel>> searchUsersByEmail(String email) async {
    try {
      final snapshot = await firestore
          .collection(usersCollection)
          .where('email', isGreaterThanOrEqualTo: email)
          .where('email', isLessThan: email + 'z')
          .get();

      return snapshot.docs
          .map((doc) => AdminUserModel.fromJson({...doc.data(), 'uid': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  /// Get user by UID
  Future<AdminUserModel?> getUserByUid(String uid) async {
    try {
      final doc = await firestore.collection(usersCollection).doc(uid).get();
      if (!doc.exists) return null;
      return AdminUserModel.fromJson({
        ...doc.data() as Map<String, dynamic>,
        'uid': uid,
      });
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  /// Update user
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await firestore.collection(usersCollection).doc(uid).update(data);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  /// Suspend/Unsuspend user
  Future<void> suspendUser(String uid, String reason) async {
    try {
      await firestore.collection(usersCollection).doc(uid).update({
        'accountStatus': 'suspended',
        'suspendedAt': DateTime.now().toIso8601String(),
        'suspensionReason': reason,
      });
    } catch (e) {
      throw Exception('Failed to suspend user: $e');
    }
  }

  /// Reactivate user
  Future<void> reactivateUser(String uid) async {
    try {
      await firestore.collection(usersCollection).doc(uid).update({
        'accountStatus': 'active',
        'suspendedAt': null,
        'suspensionReason': null,
      });
    } catch (e) {
      throw Exception('Failed to reactivate user: $e');
    }
  }

  /// ============ Blood Donor Management ============

  /// Get all blood donors
  Future<List<BloodDonorModel>> getAllBloodDonors({
    int limit = 10,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = firestore.collection(bloodDonorsCollection).limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map(
            (doc) => BloodDonorModel.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'uid': doc.id,
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch blood donors: $e');
    }
  }

  /// Search blood donors by blood group
  Future<List<BloodDonorModel>> searchDonorsByBloodGroup(
    String bloodGroup,
  ) async {
    try {
      final snapshot = await firestore
          .collection(bloodDonorsCollection)
          .where('bloodGroup', isEqualTo: bloodGroup)
          .get();

      return snapshot.docs
          .map(
            (doc) => BloodDonorModel.fromJson({...doc.data(), 'uid': doc.id}),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to search donors: $e');
    }
  }

  /// Filter donors by location
  Future<List<BloodDonorModel>> filterDonorsByLocation(
    String district,
    String town,
  ) async {
    try {
      var query = firestore.collection(bloodDonorsCollection) as dynamic;

      if (district.isNotEmpty) {
        query = query.where('district', isEqualTo: district);
      }
      if (town.isNotEmpty) {
        query = query.where('town', isEqualTo: town);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map(
            (doc) => BloodDonorModel.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'uid': doc.id,
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to filter donors: $e');
    }
  }

  /// Get donor by UID
  Future<BloodDonorModel?> getDonorByUid(String uid) async {
    try {
      final doc = await firestore
          .collection(bloodDonorsCollection)
          .doc(uid)
          .get();
      if (!doc.exists) return null;
      return BloodDonorModel.fromJson({
        ...doc.data() as Map<String, dynamic>,
        'uid': uid,
      });
    } catch (e) {
      throw Exception('Failed to fetch donor: $e');
    }
  }

  /// Update blood donor
  Future<void> updateBloodDonor(String uid, Map<String, dynamic> data) async {
    try {
      await firestore.collection(bloodDonorsCollection).doc(uid).update(data);
    } catch (e) {
      throw Exception('Failed to update donor: $e');
    }
  }

  /// ============ Category Management ============

  /// Get all categories
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final snapshot = await firestore
          .collection(categoriesCollection)
          .orderBy('displayOrder')
          .get();

      return snapshot.docs
          .map((doc) => CategoryModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  /// Create category
  Future<String> createCategory(CategoryModel category) async {
    try {
      final docRef = await firestore
          .collection(categoriesCollection)
          .add(category.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  /// Update category
  Future<void> updateCategory(
    String categoryId,
    Map<String, dynamic> data,
  ) async {
    try {
      await firestore
          .collection(categoriesCollection)
          .doc(categoryId)
          .update(data);
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  /// Delete category
  Future<void> deleteCategory(String categoryId) async {
    try {
      await firestore.collection(categoriesCollection).doc(categoryId).delete();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  /// ============ Emergency Numbers Management ============

  /// Get all emergency numbers
  Future<List<EmergencyNumberModel>> getAllEmergencyNumbers() async {
    try {
      final snapshot = await firestore
          .collection(emergencyNumbersCollection)
          .orderBy('priority')
          .get();

      return snapshot.docs
          .map(
            (doc) =>
                EmergencyNumberModel.fromJson({...doc.data(), 'id': doc.id}),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch emergency numbers: $e');
    }
  }

  /// Create emergency number
  Future<String> createEmergencyNumber(
    EmergencyNumberModel emergencyNumber,
  ) async {
    try {
      final docRef = await firestore
          .collection(emergencyNumbersCollection)
          .add(emergencyNumber.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create emergency number: $e');
    }
  }

  /// Update emergency number
  Future<void> updateEmergencyNumber(
    String numberId,
    Map<String, dynamic> data,
  ) async {
    try {
      await firestore
          .collection(emergencyNumbersCollection)
          .doc(numberId)
          .update(data);
    } catch (e) {
      throw Exception('Failed to update emergency number: $e');
    }
  }

  /// Delete emergency number
  Future<void> deleteEmergencyNumber(String numberId) async {
    try {
      await firestore
          .collection(emergencyNumbersCollection)
          .doc(numberId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete emergency number: $e');
    }
  }

  /// ============ Resources Management ============

  /// Get all resources
  Future<List<ResourceModel>> getAllResources({int limit = 20}) async {
    try {
      final snapshot = await firestore
          .collection(resourcesCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ResourceModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch resources: $e');
    }
  }

  /// Create resource
  Future<String> createResource(ResourceModel resource) async {
    try {
      final docRef = await firestore
          .collection(resourcesCollection)
          .add(resource.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create resource: $e');
    }
  }

  /// Update resource
  Future<void> updateResource(
    String resourceId,
    Map<String, dynamic> data,
  ) async {
    try {
      await firestore
          .collection(resourcesCollection)
          .doc(resourceId)
          .update(data);
    } catch (e) {
      throw Exception('Failed to update resource: $e');
    }
  }

  /// ============ Conditions Management ============

  /// Get all conditions
  Future<List<ConditionModel>> getAllConditions({int limit = 20}) async {
    try {
      final snapshot = await firestore
          .collection(conditionsCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ConditionModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch conditions: $e');
    }
  }

  /// Create condition
  Future<String> createCondition(ConditionModel condition) async {
    try {
      final docRef = await firestore
          .collection(conditionsCollection)
          .add(condition.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create condition: $e');
    }
  }

  /// Update condition
  Future<void> updateCondition(
    String conditionId,
    Map<String, dynamic> data,
  ) async {
    try {
      await firestore
          .collection(conditionsCollection)
          .doc(conditionId)
          .update(data);
    } catch (e) {
      throw Exception('Failed to update condition: $e');
    }
  }
}
