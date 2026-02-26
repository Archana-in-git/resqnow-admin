import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:rxdart/rxdart.dart';
import 'package:resqnow_admin/features/admin/data/models/admin_user_model.dart';
import 'package:resqnow_admin/features/admin/data/models/blood_donor_model.dart';
import 'package:resqnow_admin/features/admin/data/models/resource_models.dart';
import 'package:resqnow_admin/features/admin/data/models/analytics_model.dart';

/// Core Admin Service for Firestore operations
class AdminService {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseFunctions functions;

  // Firestore collection names (matching main app structure)
  static const String usersCollection = 'users';
  static const String donorsCollection = 'donors'; // matches main app
  static const String categoriesCollection = 'categories';
  static const String emergencyNumbersCollection = 'emergency_numbers';
  static const String resourcesCollection = 'resources';
  static const String conditionsCollection =
      'medical_conditions'; // matches main app
  static const String callRequestsCollection = 'call_requests';
  static const String notificationsCollection = 'notifications';

  AdminService({
    required this.firestore,
    required this.auth,
    FirebaseFunctions? functions,
  }) : functions = functions ?? FirebaseFunctions.instance;

  /// Verify current user is an admin
  Future<bool> isCurrentUserAdmin() async {
    try {
      final user = auth.currentUser;
      if (user == null) return false;

      final userDoc = await firestore
          .collection(usersCollection)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) return false;

      final role = userDoc.get('role') as String?;
      return role == 'admin';
    } catch (e) {
      return false;
    }
  }

  /// Get current user's role
  Future<String?> getCurrentUserRole() async {
    try {
      final user = auth.currentUser;
      if (user == null) return null;

      final userDoc = await firestore
          .collection(usersCollection)
          .doc(user.uid)
          .get();

      return userDoc.get('role') as String?;
    } catch (e) {
      return null;
    }
  }

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
      print('DEBUG: Fetched ${snapshot.docs.length} users from Firestore');

      List<AdminUserModel> users = [];
      for (var doc in snapshot.docs) {
        try {
          final userData = doc.data() as Map<String, dynamic>;
          final user = AdminUserModel.fromJson({...userData, 'uid': doc.id});
          users.add(user);
        } catch (e) {
          print('ERROR: Failed to parse user ${doc.id}: $e');
          print('  Data: ${doc.data()}');
          // Continue processing other users
        }
      }

      print('DEBUG: Successfully parsed ${users.length} users');
      return users;
    } catch (e) {
      print('ERROR: getAllUsers failed: $e');
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

  /// Suspend/Unsuspend user - immediately blocks access
  Future<void> suspendUser(String uid, String reason) async {
    try {
      await functions.httpsCallable('suspendUserAccount').call({
        'uid': uid,
        'reason': reason,
      });

      await firestore.collection(usersCollection).doc(uid).update({
        'accountStatus': 'suspended',
        'suspendedAt': FieldValue.serverTimestamp(),
        'suspensionReason': reason,
        'isBlocked': true,
      });
    } on FirebaseFunctionsException catch (e) {
      final detail = e.details != null ? ' | details: ${e.details}' : '';
      throw Exception(
        'Suspend failed [${e.code}]: ${e.message ?? 'Unknown function error'}$detail',
      );
    } catch (e) {
      throw Exception('Failed to suspend user: $e');
    }
  }

  /// Reactivate user
  Future<void> reactivateUser(String uid) async {
    try {
      await functions.httpsCallable('reactivateUserAccount').call({'uid': uid});

      await firestore.collection(usersCollection).doc(uid).update({
        'accountStatus': 'active',
        'suspendedAt': null,
        'suspensionReason': null,
        'isBlocked': false,
      });
    } on FirebaseFunctionsException catch (e) {
      final detail = e.details != null ? ' | details: ${e.details}' : '';
      throw Exception(
        'Reactivation failed [${e.code}]: ${e.message ?? 'Unknown function error'}$detail',
      );
    } catch (e) {
      throw Exception('Failed to reactivate user: $e');
    }
  }

  /// Delete user completely - removes auth account and all data
  Future<void> deleteUser(String uid) async {
    try {
      await functions.httpsCallable('deleteUserAccountCompletely').call({
        'uid': uid,
      });
    } on FirebaseFunctionsException catch (e) {
      final detail = e.details != null ? ' | details: ${e.details}' : '';
      throw Exception(
        'Delete failed [${e.code}]: ${e.message ?? 'Unknown function error'}$detail',
      );
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  /// Check if user is suspended
  Future<bool> isUserSuspended(String uid) async {
    try {
      final userDoc = await firestore
          .collection(usersCollection)
          .doc(uid)
          .get();

      if (!userDoc.exists) return false;
      return userDoc.get('accountStatus') == 'suspended';
    } catch (e) {
      return false;
    }
  }

  /// ============ Blood Donor Management ============

  /// Get all blood donors
  Future<List<BloodDonorModel>> getAllBloodDonors({
    int limit = 10,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = firestore.collection(donorsCollection).limit(limit);

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
          .collection(donorsCollection)
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
      var query = firestore.collection(donorsCollection) as dynamic;

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
      final doc = await firestore.collection(donorsCollection).doc(uid).get();
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
      await firestore.collection(donorsCollection).doc(uid).update(data);
    } catch (e) {
      throw Exception('Failed to update donor: $e');
    }
  }

  /// Suspend blood donor
  Future<void> suspendDonor(String uid, String reason) async {
    try {
      await firestore.collection(donorsCollection).doc(uid).update({
        'isSuspended': true,
        'suspensionReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to suspend donor: $e');
    }
  }

  /// Reactivate blood donor
  Future<void> reactivateDonor(String uid) async {
    try {
      await firestore.collection(donorsCollection).doc(uid).update({
        'isSuspended': false,
        'suspensionReason': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to reactivate donor: $e');
    }
  }

  /// Delete blood donor
  Future<void> deleteDonor(String uid) async {
    try {
      await firestore.collection(donorsCollection).doc(uid).delete();
    } catch (e) {
      throw Exception('Failed to delete donor: $e');
    }
  }

  /// ============ Category Management ============

  /// Get all categories
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final snapshot = await firestore
          .collection(categoriesCollection)
          .orderBy('order')
          .get();

      return snapshot.docs
          .map((doc) => CategoryModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  /// Create category with auto-shifting of order values
  /// When creating a category with order=X, all categories with order≥X are incremented by 1
  Future<String> createCategory(CategoryModel category) async {
    try {
      final orderValue = category.order ?? 999;

      // Shift existing categories if order conflicts
      if (orderValue < 999) {
        final conflictingDocs = await firestore
            .collection(categoriesCollection)
            .where('order', isGreaterThanOrEqualTo: orderValue)
            .get();

        // Increment order for all conflicting categories
        for (var doc in conflictingDocs.docs) {
          final currentOrder = doc.get('order') as int? ?? 999;
          await firestore.collection(categoriesCollection).doc(doc.id).update({
            'order': currentOrder + 1,
          });
        }
      }

      // Now create the new category
      final docRef = await firestore
          .collection(categoriesCollection)
          .add(category.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  /// Update category with auto-shifting of order values
  /// When updating category order to X, all other categories with conflicting order are shifted
  Future<void> updateCategory(
    String categoryId,
    Map<String, dynamic> data,
  ) async {
    try {
      // If order is being updated, handle shifting
      if (data.containsKey('order')) {
        final newOrder = data['order'] as int? ?? 999;

        // Get the current category to find its old order
        final currentDoc = await firestore
            .collection(categoriesCollection)
            .doc(categoryId)
            .get();
        final oldOrder = currentDoc.get('order') as int? ?? 999;

        // Only shift if order is actually changing
        if (newOrder != oldOrder && newOrder < 999) {
          if (newOrder < oldOrder) {
            // Moving to a lower order number: shift up categories between newOrder and oldOrder
            final conflictingDocs = await firestore
                .collection(categoriesCollection)
                .where('order', isGreaterThanOrEqualTo: newOrder)
                .where('order', isLessThan: oldOrder)
                .get();

            for (var doc in conflictingDocs.docs) {
              if (doc.id != categoryId) {
                final currentOrder = doc.get('order') as int? ?? 999;
                await firestore
                    .collection(categoriesCollection)
                    .doc(doc.id)
                    .update({'order': currentOrder + 1});
              }
            }
          } else {
            // Moving to a higher order number: shift down categories between oldOrder and newOrder
            final conflictingDocs = await firestore
                .collection(categoriesCollection)
                .where('order', isGreaterThan: oldOrder)
                .where('order', isLessThanOrEqualTo: newOrder)
                .get();

            for (var doc in conflictingDocs.docs) {
              if (doc.id != categoryId) {
                final currentOrder = doc.get('order') as int? ?? 999;
                await firestore
                    .collection(categoriesCollection)
                    .doc(doc.id)
                    .update({'order': currentOrder - 1});
              }
            }
          }
        }
      }

      // Update the category with provided data
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

  /// Migrate all categories to use filename-only icon assets
  /// Extracts filename from full paths and updates all categories
  Future<int> migrateCategoriesToFilenamesOnly() async {
    try {
      final snapshot = await firestore.collection(categoriesCollection).get();
      int updated = 0;

      for (var doc in snapshot.docs) {
        final iconAsset = doc.get('iconAsset') as String?;

        if (iconAsset != null && iconAsset.isNotEmpty) {
          // Extract filename from any path format
          var normalizedPath = iconAsset.replaceAll('\\', '/');
          var filename = normalizedPath.split('/').last;

          // Only update if it's different (i.e., had a path)
          if (filename != iconAsset) {
            await firestore.collection(categoriesCollection).doc(doc.id).update(
              {'iconAsset': filename},
            );
            updated++;
          }
        }
      }

      return updated;
    } catch (e) {
      throw Exception('Failed to migrate categories: $e');
    }
  }

  /// Fix duplicate order values by renumbering all categories sequentially
  /// Categories are renumbered 1, 2, 3, ... based on their current order and name
  Future<int> fixDuplicateOrders() async {
    try {
      final snapshot = await firestore.collection(categoriesCollection).get();

      // Sort by current order, then by name (as tiebreaker for duplicates)
      final docs = snapshot.docs.toList();
      docs.sort((a, b) {
        final orderA = a.get('order') as int? ?? 999;
        final orderB = b.get('order') as int? ?? 999;
        if (orderA != orderB) return orderA.compareTo(orderB);

        final nameA = a.get('name') as String? ?? '';
        final nameB = b.get('name') as String? ?? '';
        return nameA.compareTo(nameB);
      });

      // Renumber sequentially
      int newOrder = 1;
      for (var doc in docs) {
        await firestore.collection(categoriesCollection).doc(doc.id).update({
          'order': newOrder,
        });
        newOrder++;
      }

      return docs.length;
    } catch (e) {
      throw Exception('Failed to fix duplicate orders: $e');
    }
  }

  /// ============ Emergency Numbers Management ============

  /// Get all emergency numbers
  Future<List<EmergencyNumberModel>> getAllEmergencyNumbers() async {
    try {
      final snapshot = await firestore
          .collection(emergencyNumbersCollection)
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

  /// Delete resource
  Future<void> deleteResource(String resourceId) async {
    try {
      await firestore.collection(resourcesCollection).doc(resourceId).delete();
    } catch (e) {
      throw Exception('Failed to delete resource: $e');
    }
  }

  /// ============ Conditions Management ============

  /// Get all conditions
  Future<List<ConditionModel>> getAllConditions({int limit = 20}) async {
    try {
      print(
        '🔍 AdminService: Fetching conditions from collection: "$conditionsCollection"',
      );
      Query query = firestore.collection(conditionsCollection);

      print('📊 AdminService: Executing query with limit: $limit');
      final snapshot = await query.limit(limit).get();

      print(
        '✅ AdminService: Got snapshot with ${snapshot.docs.length} documents',
      );

      if (snapshot.docs.isEmpty) {
        print(
          '⚠️ AdminService: No documents found in collection "$conditionsCollection"',
        );
        return [];
      }

      List<ConditionModel> conditions = [];
      for (int i = 0; i < snapshot.docs.length; i++) {
        try {
          final doc = snapshot.docs[i];
          print(
            '📄 Document $i: ID=${doc.id}, data keys=${(doc.data() as Map<String, dynamic>).keys.toList()}',
          );
          final condition = ConditionModel.fromJson({
            ...doc.data() as Map<String, dynamic>,
            'id': doc.id,
          });
          conditions.add(condition);
          print('   ✅ Parsed: ${condition.name}');
        } catch (e, st) {
          print('   ❌ Error parsing document: $e');
          print('   Stack: $st');
        }
      }

      print(
        '📋 AdminService: Successfully parsed ${conditions.length} conditions',
      );

      // Sort by createdAt descending (most recent first) if available
      conditions.sort((a, b) {
        if (a.createdAt != null && b.createdAt != null) {
          return b.createdAt!.compareTo(a.createdAt!);
        } else if (a.createdAt != null) {
          return -1;
        } else if (b.createdAt != null) {
          return 1;
        }
        return 0;
      });

      print('✨ AdminService: Returning ${conditions.length} conditions');
      return conditions;
    } catch (e, stackTrace) {
      print('❌ AdminService: Error fetching conditions: $e');
      print('📍 Stack trace: $stackTrace');
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

  /// Delete condition
  Future<void> deleteCondition(String conditionId) async {
    try {
      await firestore
          .collection(conditionsCollection)
          .doc(conditionId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete condition: $e');
    }
  }

  /// ============ Analytics ============

  /// Get dashboard statistics
  Future<AnalyticsStats> getAnalyticsStats() async {
    try {
      // Total Users (all accounts, including suspended)
      int totalUsers = 0;
      try {
        final totalUsersSnap = await firestore
            .collection(usersCollection)
            .count()
            .get();
        totalUsers = totalUsersSnap.count ?? 0;
      } catch (e) {
        // Handle permission or collection errors
        totalUsers = 0;
      }

      // Active Users (users with accountStatus = 'active' and isBlocked = false)
      int activeUsersCount = 0;
      try {
        final activeUsersSnap = await firestore
            .collection(usersCollection)
            .where('accountStatus', isEqualTo: 'active')
            .where('isBlocked', isEqualTo: false)
            .count()
            .get();
        activeUsersCount = activeUsersSnap.count ?? 0;
      } catch (e) {
        print('Error fetching active users: $e');
        activeUsersCount = 0;
      }

      // Suspended Users Count
      int suspendedUsersCount = 0;
      try {
        final suspendedSnap = await firestore
            .collection(usersCollection)
            .where('accountStatus', isEqualTo: 'suspended')
            .count()
            .get();
        suspendedUsersCount = suspendedSnap.count ?? 0;
      } catch (e) {
        suspendedUsersCount = 0;
      }

      // New Users Last 7 Days (all created in last 7 days)
      int newUsersLastWeek = 0;
      int activeNewUsersLastWeek = 0;
      try {
        final sevenDaysAgo = Timestamp.fromDate(
          DateTime.now().subtract(Duration(days: 7)),
        );
        final newUsersSnap = await firestore
            .collection(usersCollection)
            .where('createdAt', isGreaterThanOrEqualTo: sevenDaysAgo)
            .get();
        newUsersLastWeek = newUsersSnap.docs.length;

        // Count active new users
        activeNewUsersLastWeek = newUsersSnap.docs.where((doc) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            return (data['accountStatus'] as String?) == 'active' &&
                (data['isBlocked'] as bool?) == false;
          } catch (e) {
            return false;
          }
        }).length;
      } catch (e) {
        print('Error fetching new users: $e');
        newUsersLastWeek = 0;
        activeNewUsersLastWeek = 0;
      }

      // Active Donors
      int activeDonors = 0;
      try {
        final activeDonorsSnap = await firestore
            .collection(donorsCollection)
            .where('isAvailable', isEqualTo: true)
            .count()
            .get();
        activeDonors = activeDonorsSnap.count ?? 0;
      } catch (e) {
        activeDonors = 0;
      }

      // Emergency Clicks Today (optimized with .count() and Timestamp)
      int emergencyClicksToday = 0;
      try {
        final today = DateTime.now();
        final startOfDay = Timestamp.fromDate(
          DateTime(today.year, today.month, today.day),
        );
        final endOfDay = Timestamp.fromDate(
          DateTime(today.year, today.month, today.day + 1),
        );

        final emergencyClicksSnap = await firestore
            .collection('emergency_logs')
            .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
            .where('timestamp', isLessThan: endOfDay)
            .count()
            .get();
        emergencyClicksToday = emergencyClicksSnap.count ?? 0;
      } catch (e) {
        emergencyClicksToday = 0;
      }

      // Most Searched Condition
      String mostSearchedCondition = 'N/A';
      final sevenDaysAgoForSearch = DateTime.now()
          .subtract(Duration(days: 7))
          .toIso8601String();
      try {
        final searchLogsSnap = await firestore
            .collection('search_logs')
            .where('timestamp', isGreaterThanOrEqualTo: sevenDaysAgoForSearch)
            .get();

        if (searchLogsSnap.docs.isNotEmpty) {
          // Count occurrences of each query
          final queryCount = <String, int>{};
          for (var doc in searchLogsSnap.docs) {
            final query = doc.get('query') as String?;
            if (query != null && query.isNotEmpty) {
              queryCount[query] = (queryCount[query] ?? 0) + 1;
            }
          }

          // Find the most searched query
          if (queryCount.isNotEmpty) {
            final mostSearched = queryCount.entries.reduce(
              (a, b) => a.value > b.value ? a : b,
            );
            mostSearchedCondition = mostSearched.key;
          }
        }
      } catch (e) {
        // Collection might not exist
        print('Error fetching search logs: $e');
      }

      return AnalyticsStats(
        totalUsers: totalUsers,
        activeUsersCount: activeUsersCount,
        suspendedUsersCount: suspendedUsersCount,
        newUsersLastWeek: newUsersLastWeek,
        activeNewUsersLastWeek: activeNewUsersLastWeek,
        activeDonors: activeDonors,
        emergencyClicksToday: emergencyClicksToday,
        mostSearchedCondition: mostSearchedCondition,
        userGrowthPercent: totalUsers > 0
            ? (newUsersLastWeek / totalUsers * 100)
            : 0,
        donorGrowthPercent: activeDonors > 0 ? 5.2 : 0,
        emergencyTrendsPercent: emergencyClicksToday > 0 ? 3.8 : 0,
        activeUsersPercent: totalUsers > 0
            ? (activeUsersCount / totalUsers * 100)
            : 0,
      );
    } catch (e) {
      // Final fallback - return empty stats instead of throwing error
      return AnalyticsStats.empty();
    }
  }

  /// Get user growth data for chart
  Future<UserGrowthData> getUserGrowthData({int months = 6}) async {
    try {
      final now = DateTime.now();
      final monthLabels = <String>[];
      final userCounts = <int>[];

      for (int i = months - 1; i >= 0; i--) {
        final monthDate = DateTime(now.year, now.month - i, 1);
        final monthStr =
            '${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}';
        monthLabels.add(monthStr);

        // Get user count for this month using Firestore Timestamps
        final startOfMonth = Timestamp.fromDate(
          DateTime(monthDate.year, monthDate.month, 1),
        );
        final endOfMonth = Timestamp.fromDate(
          DateTime(monthDate.year, monthDate.month + 1, 1),
        );

        try {
          final snap = await firestore
              .collection(usersCollection)
              .where('createdAt', isGreaterThanOrEqualTo: startOfMonth)
              .where('createdAt', isLessThan: endOfMonth)
              .count()
              .get();
          userCounts.add(snap.count ?? 0);
        } catch (e) {
          userCounts.add(0);
        }
      }

      return UserGrowthData(months: monthLabels, userCounts: userCounts);
    } catch (e) {
      print('Error fetching user growth data: $e');
      // Return empty chart on error instead of throwing
      return UserGrowthData(months: [], userCounts: []);
    }
  }

  /// Get emergency trend data (optimized query)
  Future<EmergencyTrendData> getEmergencyTrendData({int days = 7}) async {
    try {
      final labels = <String>[];
      final counts = <int>[];

      // Query logs for each day using efficient .count() method
      for (int i = days - 1; i >= 0; i--) {
        final date = DateTime.now().subtract(Duration(days: i));
        final dateStr = '${date.month}/${date.day}';
        labels.add(dateStr);

        final startOfDay = Timestamp.fromDate(
          DateTime(date.year, date.month, date.day),
        );
        final endOfDay = Timestamp.fromDate(
          DateTime(date.year, date.month, date.day + 1),
        );

        try {
          final snap = await firestore
              .collection('emergency_logs')
              .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
              .where('timestamp', isLessThan: endOfDay)
              .count()
              .get();
          counts.add(snap.count ?? 0);
        } catch (e) {
          counts.add(0);
        }
      }

      return EmergencyTrendData(labels: labels, counts: counts);
    } catch (e) {
      // Return empty chart on error
      return EmergencyTrendData(labels: [], counts: []);
    }
  }

  /// Get top medical conditions
  Future<List<TopConditionData>> getTopConditions({int limit = 5}) async {
    try {
      final conditions = <TopConditionData>[];
      final conditionsSnap = await firestore
          .collection(conditionsCollection)
          .limit(limit)
          .get();

      int totalViews = 0;
      for (var doc in conditionsSnap.docs) {
        final viewCount = (doc.get('viewCount') as num?)?.toInt() ?? 0;
        totalViews += viewCount;
      }

      for (var doc in conditionsSnap.docs) {
        final name = doc.get('name') as String? ?? 'Unknown';
        final viewCount = (doc.get('viewCount') as num?)?.toInt() ?? 0;
        final percentage = totalViews > 0 ? (viewCount / totalViews * 100) : 0;

        conditions.add(
          TopConditionData(
            conditionName: name,
            viewCount: viewCount,
            percentage: percentage as double,
          ),
        );
      }

      return conditions;
    } catch (e) {
      // Return empty list on error
      return [];
    }
  }

  /// Get content status metrics
  Future<ContentStatusMetrics> getContentStatusMetrics() async {
    try {
      // Total Conditions
      final conditionsSnap = await firestore
          .collection(conditionsCollection)
          .count()
          .get();
      final totalConditions = conditionsSnap.count ?? 0;

      // Conditions missing video/images
      int missingVideo = 0;
      int missingImages = 0;
      final allConditions = await firestore
          .collection(conditionsCollection)
          .get();

      for (var doc in allConditions.docs) {
        if (doc.get('videoUrl') == null ||
            (doc.get('videoUrl') as String).isEmpty) {
          missingVideo++;
        }
        if (doc.get('imageUrl') == null ||
            (doc.get('imageUrl') as String).isEmpty) {
          missingImages++;
        }
      }

      // Draft vs Published (mock data)
      final draftItems = (totalConditions * 0.1).toInt();
      final publishedItems = totalConditions - draftItems;

      return ContentStatusMetrics(
        totalConditions: totalConditions,
        conditionsMissingVideo: missingVideo,
        conditionsMissingImages: missingImages,
        lastUpdatedContent: DateTime.now(),
        draftItems: draftItems,
        publishedItems: publishedItems,
        firebaseStorageUsedGB: 2.5, // Mock data
        firestoreDocumentCount: totalConditions + 100,
        failedApiCalls: 3,
        errorLogsCount: 12,
        appVersionActive: '1.0.0',
        crashReportsCount: 1,
      );
    } catch (e) {
      // Return basic metrics on error
      return ContentStatusMetrics(
        totalConditions: 0,
        conditionsMissingVideo: 0,
        conditionsMissingImages: 0,
        lastUpdatedContent: DateTime.now(),
        draftItems: 0,
        publishedItems: 0,
        firebaseStorageUsedGB: 0,
        firestoreDocumentCount: 0,
        failedApiCalls: 0,
        errorLogsCount: 0,
        appVersionActive: '1.0.0',
        crashReportsCount: 0,
      );
    }
  }

  /// Get real-time activity panel data
  Future<RealTimeActivityPanel> getRealTimeActivityData() async {
    try {
      final activities = <RecentActivityItem>[];

      // Get recent activities from different collections
      try {
        // Recent users
        final usersSnap = await firestore
            .collection(usersCollection)
            .orderBy('createdAt', descending: true)
            .limit(3)
            .get();

        for (var doc in usersSnap.docs) {
          activities.add(
            RecentActivityItem(
              type: 'user_registered',
              title: 'New User Registered',
              description: doc.get('email') ?? 'Unknown User',
              timestamp: DateTime.parse(
                doc.get('createdAt') ?? DateTime.now().toIso8601String(),
              ),
              userId: doc.id,
            ),
          );
        }
      } catch (e) {
        // Handle error
      }

      // Get today's emergency logs count (optimized with .count() for speed)
      int emergencyCountToday = 0;
      try {
        final today = DateTime.now();
        final startOfDay = Timestamp.fromDate(
          DateTime(today.year, today.month, today.day),
        );
        final endOfDay = Timestamp.fromDate(
          DateTime(today.year, today.month, today.day + 1),
        );

        // Use count() for O(1) query instead of fetching all documents
        final emergencyCountSnap = await firestore
            .collection('emergency_logs')
            .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
            .where('timestamp', isLessThan: endOfDay)
            .count()
            .get();

        emergencyCountToday = emergencyCountSnap.count ?? 0;
      } catch (e) {
        // Collection might not exist - continue without data
        print('Note: emergency_logs collection not found or empty');
      }

      return RealTimeActivityPanel(
        recentActivities: activities,
        liveEmergencyRequestsToday: emergencyCountToday,
        mostEmergencyTriggeredLocation: 'Real-Time Tracking',
        mostCommonEmergencyType: 'Direct Call',
        peakUsageHour: 'All Hours',
      );
    } catch (e) {
      // Return empty activity panel on error
      return RealTimeActivityPanel(
        recentActivities: [],
        liveEmergencyRequestsToday: 0,
        mostEmergencyTriggeredLocation: 'N/A',
        mostCommonEmergencyType: 'N/A',
        peakUsageHour: 'N/A',
      );
    }
  }

  /// Send notification to users
  /// Creates individual notification documents for each matching user
  Future<void> sendNotification({
    required String title,
    required String message,
    required String
    recipientType, // 'all_users', 'donors_only', 'specific_district'
    String? targetDistrict,
  }) async {
    try {
      print('📤 Sending notification to users...');
      print('   Title: $title');
      print('   Message: $message');
      print('   Recipient Type: $recipientType');
      print('   Target District: $targetDistrict');

      // Build query based on recipient type
      Query query = firestore.collection(usersCollection);

      if (recipientType == 'donors_only') {
        // Only send to donors
        query = query.where('role', isEqualTo: 'donor');
        if (targetDistrict != null && targetDistrict.isNotEmpty) {
          query = query.where('district', isEqualTo: targetDistrict);
        }
      } else if (recipientType == 'specific_district') {
        // Send to all users in specific district
        if (targetDistrict != null && targetDistrict.isNotEmpty) {
          query = query.where('district', isEqualTo: targetDistrict);
        }
      }
      // else: 'all_users' - send to everyone (no additional filters)

      // Fetch matching users
      final userDocs = await query.get();
      print('✅ Found ${userDocs.docs.length} matching users');

      if (userDocs.docs.isEmpty) {
        print('⚠️ No matching users found for this notification');
        return;
      }

      // Create individual notification for each user
      final batch = firestore.batch();
      final timestamp = DateTime.now();

      for (final userDoc in userDocs.docs) {
        final userId = userDoc.id;
        final notificationRef = firestore
            .collection(notificationsCollection)
            .doc();

        batch.set(notificationRef, {
          'userId': userId,
          'title': title,
          'message': message,
          'type': 'general',
          'createdAt': timestamp,
          'isRead': false,
          'recipientType': recipientType,
          'targetDistrict': targetDistrict,
        });

        print('📬 Created notification for user: $userId');
      }

      await batch.commit();
      print('✅ All ${userDocs.docs.length} notifications created successfully');
    } catch (e) {
      print('❌ Error sending notification: $e');
      throw Exception('Failed to send notification: $e');
    }
  }

  /// Get sent notifications history
  Future<List<NotificationSchedule>> getNotificationHistory({
    int limit = 10,
  }) async {
    try {
      final snap = await firestore
          .collection('notifications')
          .orderBy('sentTime', descending: true)
          .limit(limit)
          .get();

      return snap.docs
          .map(
            (doc) => NotificationSchedule(
              id: doc.id,
              title: doc.get('title') ?? '',
              message: doc.get('message') ?? '',
              recipientType: doc.get('recipientType') ?? 'all_users',
              targetDistrict: doc.get('targetDistrict'),
              scheduledTime: DateTime.now(),
              sentTime: DateTime.parse(
                doc.get('sentTime') ?? DateTime.now().toIso8601String(),
              ),
              isSent: true,
              deliveredCount: (doc.get('deliveredCount') as num?)?.toInt() ?? 0,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch notification history: $e');
    }
  }

  /// Get admin security metrics
  Future<AdminSecurityMetrics> getAdminSecurityMetrics(String adminUid) async {
    try {
      final adminDoc = await firestore
          .collection(usersCollection)
          .doc(adminUid)
          .get();

      final role = adminDoc.get('role') as String? ?? 'admin';
      final lastLogin = DateTime.parse(
        adminDoc.get('lastLogin') ?? DateTime.now().toIso8601String(),
      );

      // Mock login logs
      final recentLogins = <LoginLog>[
        LoginLog(
          timestamp: DateTime.now(),
          ipAddress: '192.168.1.1',
          device: 'Chrome on Windows',
          successful: true,
        ),
        LoginLog(
          timestamp: DateTime.now().subtract(Duration(days: 1)),
          ipAddress: '192.168.1.2',
          device: 'Safari on macOS',
          successful: true,
        ),
      ];

      return AdminSecurityMetrics(
        adminRole: role,
        lastLogin: lastLogin,
        recentLogins: recentLogins,
        suspiciousActivities: [],
      );
    } catch (e) {
      throw Exception('Failed to fetch admin security metrics: $e');
    }
  }

  /// ============ Call Request Management ============

  /// Get all call requests (with optional filtering)
  Future<List<Map<String, dynamic>>> getAllCallRequests({
    String? status,
    String? donorId,
    int limit = 50,
  }) async {
    try {
      Query query = firestore.collection(callRequestsCollection);

      if (status != null && status != 'all') {
        query = query.where('status', isEqualTo: status);
      }

      if (donorId != null) {
        query = query.where('donorId', isEqualTo: donorId);
      }

      final snapshot = await query
          .orderBy('requestedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch call requests: $e');
    }
  }

  /// Get pending call requests count
  Future<int> getPendingCallRequestsCount() async {
    try {
      final snapshot = await firestore
          .collection(callRequestsCollection)
          .where('status', isEqualTo: 'pending')
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to fetch pending count: $e');
    }
  }

  /// Get call requests for a specific donor
  Future<List<Map<String, dynamic>>> getCallRequestsForDonor(
    String donorId, {
    String? status,
  }) async {
    try {
      Query query = firestore
          .collection(callRequestsCollection)
          .where('donorId', isEqualTo: donorId);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      final snapshot = await query
          .orderBy('requestedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch donor call requests: $e');
    }
  }

  /// Approve a call request
  /// Approve a call request and create notification for user
  Future<void> approveCallRequest(String requestId) async {
    try {
      // Fetch the call request to get user details
      final requestDoc = await firestore
          .collection(callRequestsCollection)
          .doc(requestId)
          .get();

      if (!requestDoc.exists) {
        throw Exception('Call request not found');
      }

      final requestData = requestDoc.data() as Map<String, dynamic>;
      final requesterId = requestData['requesterId'] as String?;
      final donorId = requestData['donorId'] as String?;
      final donorName = requestData['donorName'] as String?;
      final donorPhone = requestData['donorPhone'] as String?;

      if (requesterId == null || donorId == null) {
        throw Exception('Invalid call request data');
      }

      // Update call request status
      await firestore.collection(callRequestsCollection).doc(requestId).update({
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
      });

      // Create notification for the user with donor information
      await firestore.collection(notificationsCollection).add({
        'userId': requesterId,
        'title': 'Call Request Approved',
        'message':
            'Your call request has been approved. You may now contact the donor.',
        'type': 'call_approved',
        'donorId': donorId,
        'donorName': donorName,
        'donorPhone': donorPhone,
        'callRequestId': requestId,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    } catch (e) {
      throw Exception('Failed to approve call request: $e');
    }
  }

  /// Reject a call request and create notification for user
  Future<void> rejectCallRequest(String requestId, String reason) async {
    try {
      // Fetch the call request to get user details
      final requestDoc = await firestore
          .collection(callRequestsCollection)
          .doc(requestId)
          .get();

      if (!requestDoc.exists) {
        throw Exception('Call request not found');
      }

      final requestData = requestDoc.data() as Map<String, dynamic>;
      final requesterId = requestData['requesterId'] as String?;

      if (requesterId == null) {
        throw Exception('Invalid call request data');
      }

      // Update call request status
      await firestore.collection(callRequestsCollection).doc(requestId).update({
        'status': 'rejected',
        'adminNotes': reason,
      });

      // Create notification for the user about rejection
      await firestore.collection(notificationsCollection).add({
        'userId': requesterId,
        'title': 'Call Request Declined',
        'message': 'Your call request has been declined by an administrator.',
        'type': 'call_declined',
        'callRequestId': requestId,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    } catch (e) {
      throw Exception('Failed to reject call request: $e');
    }
  }

  /// Delete a call request
  Future<void> deleteCallRequest(String requestId) async {
    try {
      await firestore
          .collection(callRequestsCollection)
          .doc(requestId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete call request: $e');
    }
  }

  /// Get call request statistics
  Future<Map<String, int>> getCallRequestStats() async {
    try {
      final totalSnapshot = await firestore
          .collection(callRequestsCollection)
          .count()
          .get();
      final pendingSnapshot = await firestore
          .collection(callRequestsCollection)
          .where('status', isEqualTo: 'pending')
          .count()
          .get();
      final approvedSnapshot = await firestore
          .collection(callRequestsCollection)
          .where('status', isEqualTo: 'approved')
          .count()
          .get();
      final rejectedSnapshot = await firestore
          .collection(callRequestsCollection)
          .where('status', isEqualTo: 'rejected')
          .count()
          .get();

      return {
        'total': totalSnapshot.count ?? 0,
        'pending': pendingSnapshot.count ?? 0,
        'approved': approvedSnapshot.count ?? 0,
        'rejected': rejectedSnapshot.count ?? 0,
      };
    } catch (e) {
      throw Exception('Failed to fetch call request stats: $e');
    }
  }

  /// ============ Real-Time Analytics Streams ============

  /// Get real-time analytics stats stream with debouncing
  /// Debounces for 2 seconds to batch rapid changes and reduce query load
  Stream<AnalyticsStats> getAnalyticsStatsStream() {
    return firestore
        .collection(usersCollection)
        .snapshots()
        .debounceTime(const Duration(seconds: 2))
        .asyncMap((_) async {
          // Calculate stats only after changes settle (debounced)
          try {
            final totalUsersSnap = await firestore
                .collection(usersCollection)
                .count()
                .get();
            final totalUsers = totalUsersSnap.count ?? 0;

            final activeUsersSnap = await firestore
                .collection(usersCollection)
                .where('accountStatus', isEqualTo: 'active')
                .where('isBlocked', isEqualTo: false)
                .count()
                .get();
            final activeUsersCount = activeUsersSnap.count ?? 0;

            final suspendedSnap = await firestore
                .collection(usersCollection)
                .where('accountStatus', isEqualTo: 'suspended')
                .count()
                .get();
            final suspendedUsersCount = suspendedSnap.count ?? 0;

            final sevenDaysAgo = Timestamp.fromDate(
              DateTime.now().subtract(Duration(days: 7)),
            );
            final newUsersSnap = await firestore
                .collection(usersCollection)
                .where('createdAt', isGreaterThanOrEqualTo: sevenDaysAgo)
                .get();
            final newUsersLastWeek = newUsersSnap.docs.length;

            final activeNewUsersLastWeek = newUsersSnap.docs.where((doc) {
              try {
                final data = doc.data() as Map<String, dynamic>;
                return (data['accountStatus'] as String?) == 'active' &&
                    (data['isBlocked'] as bool?) == false;
              } catch (e) {
                return false;
              }
            }).length;

            final activeDonorsSnap = await firestore
                .collection(donorsCollection)
                .where('isAvailable', isEqualTo: true)
                .count()
                .get();
            final activeDonors = activeDonorsSnap.count ?? 0;

            final today = DateTime.now();
            final startOfDay = Timestamp.fromDate(
              DateTime(today.year, today.month, today.day),
            );
            final endOfDay = Timestamp.fromDate(
              DateTime(today.year, today.month, today.day + 1),
            );

            final emergencyClicksSnap = await firestore
                .collection('emergency_logs')
                .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
                .where('timestamp', isLessThan: endOfDay)
                .count()
                .get();
            final emergencyClicksToday = emergencyClicksSnap.count ?? 0;

            String mostSearchedCondition = 'N/A';
            final sevenDaysAgoForSearch = DateTime.now()
                .subtract(Duration(days: 7))
                .toIso8601String();
            try {
              final searchLogsSnap = await firestore
                  .collection('search_logs')
                  .where(
                    'timestamp',
                    isGreaterThanOrEqualTo: sevenDaysAgoForSearch,
                  )
                  .get();

              if (searchLogsSnap.docs.isNotEmpty) {
                final queryCount = <String, int>{};
                for (var doc in searchLogsSnap.docs) {
                  final query = doc.get('query') as String?;
                  if (query != null && query.isNotEmpty) {
                    queryCount[query] = (queryCount[query] ?? 0) + 1;
                  }
                }

                if (queryCount.isNotEmpty) {
                  final mostSearched = queryCount.entries.reduce(
                    (a, b) => a.value > b.value ? a : b,
                  );
                  mostSearchedCondition = mostSearched.key;
                }
              }
            } catch (e) {
              print('Error fetching search logs: $e');
            }

            return AnalyticsStats(
              totalUsers: totalUsers,
              activeUsersCount: activeUsersCount,
              suspendedUsersCount: suspendedUsersCount,
              newUsersLastWeek: newUsersLastWeek,
              activeNewUsersLastWeek: activeNewUsersLastWeek,
              activeDonors: activeDonors,
              emergencyClicksToday: emergencyClicksToday,
              mostSearchedCondition: mostSearchedCondition,
              userGrowthPercent: totalUsers > 0
                  ? (newUsersLastWeek / totalUsers * 100)
                  : 0,
              donorGrowthPercent: activeDonors > 0 ? 5.2 : 0,
              emergencyTrendsPercent: emergencyClicksToday > 0 ? 3.8 : 0,
              activeUsersPercent: totalUsers > 0
                  ? (activeUsersCount / totalUsers * 100)
                  : 0,
            );
          } catch (e) {
            print('Error in analytics stream: $e');
            return AnalyticsStats.empty();
          }
        });
  }

  /// Get real-time emergency clicks stream
  Stream<int> getEmergencyClicksStream() {
    final today = DateTime.now();
    final startOfDay = Timestamp.fromDate(
      DateTime(today.year, today.month, today.day),
    );

    return firestore
        .collection('emergency_logs')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Get real-time call request stats stream with debouncing
  /// Debounces for 1 second to reduce excessive query counts
  Stream<Map<String, int>> getCallRequestStatsStream() {
    return firestore
        .collection(callRequestsCollection)
        .snapshots()
        .debounceTime(const Duration(seconds: 1))
        .asyncMap((_) async {
          try {
            final totalSnapshot = await firestore
                .collection(callRequestsCollection)
                .count()
                .get();
            final pendingSnapshot = await firestore
                .collection(callRequestsCollection)
                .where('status', isEqualTo: 'pending')
                .count()
                .get();
            final approvedSnapshot = await firestore
                .collection(callRequestsCollection)
                .where('status', isEqualTo: 'approved')
                .count()
                .get();
            final rejectedSnapshot = await firestore
                .collection(callRequestsCollection)
                .where('status', isEqualTo: 'rejected')
                .count()
                .get();

            return {
              'total': totalSnapshot.count ?? 0,
              'pending': pendingSnapshot.count ?? 0,
              'approved': approvedSnapshot.count ?? 0,
              'rejected': rejectedSnapshot.count ?? 0,
            };
          } catch (e) {
            print('Error in call request stats stream: $e');
            return {'total': 0, 'pending': 0, 'approved': 0, 'rejected': 0};
          }
        });
  }
}
