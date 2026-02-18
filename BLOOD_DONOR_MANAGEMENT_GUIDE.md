# Blood Donor Management - Admin Dashboard

## Overview
The Blood Donor Management page is a comprehensive admin interface for managing blood donors in the ResQnow application. It provides full CRUD operations, filtering, search, and donor profile management.

## Features

### 1. **Donor List & Search**
- View all registered blood donors
- Search donors by:
  - Name
  - Email
  - Phone number
- Real-time search with instant filtering

### 2. **Advanced Filtering**
- Filter by blood group (O+, O-, A+, A-, B+, B-, AB+, AB-)
- Filter by district and town (location-based)
- Clear all filters with one click
- Multiple filters work together

### 3. **Donor Information Display**
Each donor card shows:
- Profile image (with fallback icon)
- Donor name and email
- Blood group (prominently displayed)
- Contact phone number
- Current status (Available/Unavailable)
- Suspension status (if suspended)
- Last donation date
- Location (Town, District)

### 4. **Donor Management Actions**

#### View Details
- Open comprehensive donor profile dialog
- View all donor information:
  - Personal information (name, email, phone, gender, age)
  - Address and location details
  - Blood group
  - Medical conditions
  - Donation history (last donation date)
  - Registration date
  - Additional notes

#### Edit Donor
- Modify donor information:
  - Name
  - Phone number
  - Location (town, district)
  - Notes
- Real-time validation and error handling
- Save changes with confirmation

#### Suspend Donor
- Suspend a donor account
- Provide reason for suspension
- Suspended donors cannot be contacted for donations
- Visible suspension flag on donor card

#### Reactivate Donor
- Reactivate suspended donors
- Removes suspension reason
- Donor becomes available for future donations

#### Delete Donor
- Permanently remove donor record
- Two-step confirmation process
- Warning about irreversible action
- Soft delete (marks as deleted, keeps data for records)

### 5. **Statistics Dashboard**
Real-time statistics bar showing:
- **Total**: Total number of donors in system
- **Available**: Donors available for donation
- **Suspended**: Number of suspended donors

### 6. **Responsive UI**
- Clean, modern interface
- Color-coded status indicators
- Clear visual hierarchy
- Mobile-friendly design

## Technical Implementation

### Architecture
```
blood_donor_management_page.dart
├── BloodDonorManagementPage (StatefulWidget)
└── _BloodDonorManagementPageState
    ├── AdminService integration
    ├── State management
    ├── Data filtering logic
    └── UI components
```

### Key Components

#### Main Page
- Search bar with real-time filtering
- Filter dropdowns
- Statistics display
- Donor list with pagination

#### Dialog Boxes
- **Details Dialog**: Comprehensive donor information view
- **Edit Dialog**: Form for updating donor information
- **Suspend Dialog**: Confirmation and reason input
- **Delete Dialog**: Confirmation with warning message

### AdminService Integration
The page uses `AdminService` for all database operations:

```dart
// Get all donors
await _adminService.getAllBloodDonors(limit: 100);

// Get donor by UID
await _adminService.getDonorByUid(uid);

// Update donor
await _adminService.updateBloodDonor(uid, {
  'field': 'value'
});

// Search and filter operations
await _adminService.searchDonorsByBloodGroup(bloodGroup);
await _adminService.filterDonorsByLocation(district, town);
```

## Usage

### Loading the Page
```dart
// In your navigation/routing
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const BloodDonorManagementPage(),
  ),
);
```

### Filtering Workflow
1. **Search**: Type in search field to find donors by name/email/phone
2. **Blood Group**: Select specific blood group from dropdown
3. **Location**: Filter by district or town (if implemented)
4. **Clear Filters**: Click "Clear Filters" button to reset all

### Managing Donors
1. **View Details**: Tap on donor card or select "View Details" from menu
2. **Edit**: Select "Edit" from menu, modify fields, save
3. **Suspend**: Select "Suspend", enter reason, confirm
4. **Reactivate**: Select "Reactivate" for suspended donors
5. **Delete**: Select "Delete", confirm warning, remove donor

## Helper Utilities

The `BloodDonorHelper` class provides:
- Color utilities for blood groups
- Date formatting helpers
- Status badge generation
- Donation eligibility checks
- Statistical calculations

```dart
// Example usage
import 'package:resqnow_admin/features/admin/presentation/utils/blood_donor_helper.dart';

// Format date
String formatted = BloodDonorHelper.formatDate(donor.registeredAt);

// Check donation eligibility
bool eligible = BloodDonorHelper.isDonationEligible(donor);

// Get statistics
Map<String, int> stats = BloodDonorHelper.getStatistics(donors);
```

## State Management

### Key State Variables
- `_allDonors`: Complete list of all donors
- `_filteredDonors`: List after applying filters
- `_isLoading`: Loading state indicator
- `_selectedBloodGroup`: Selected blood group filter
- `_selectedDistrict`: Selected district filter
- `_selectedTown`: Selected town filter

### Data Flow
1. `_loadDonors()` - Loads all donors from AdminService
2. `_applyFilters()` - Applies all active filters to `_allDonors`
3. UI rebuilds with `_filteredDonors`

## Error Handling

All operations include:
- Try-catch blocks for error handling
- User-friendly error messages via SnackBar
- Mounted checks before setState calls
- Loading states during async operations

## Future Enhancements

### Planned Features
- [ ] Export donors list to CSV/PDF
- [ ] Bulk operations (suspend, delete multiple donors)
- [ ] Advanced analytics (donation frequency, blood group needs)
- [ ] Campaign management (request specific blood types)
- [ ] Notification system for donors
- [ ] Donor rating/review system
- [ ] Medical history tracking
- [ ] Donation appointment scheduling
- [ ] Integration with SMS/Email for notifications
- [ ] Detailed reporting and analytics dashboard

### Performance Improvements
- [ ] Implement pagination for large datasets
- [ ] Add caching mechanism
- [ ] Optimize Firestore queries with indexes
- [ ] Lazy loading for donor cards

## Dependencies

```yaml
# Core dependencies used
flutter:
  widgets: Material, Scaffold, Dialog, etc.

firebase:
  - cloud_firestore
  - firebase_auth

Admin Service:
  - AdminService (custom)
  - BloodDonorModel
  - AdminConstants
```

## File Structure

```
lib/features/admin/
├── data/models/
│   └── blood_donor_model.dart
├── domain/entities/
│   └── blood_donor_entity.dart
├── presentation/
│   ├── pages/
│   │   └── blood_donor_management/
│   │       └── blood_donor_management_page.dart
│   └── utils/
│       └── blood_donor_helper.dart
```

## Testing Recommendations

### Unit Tests
- Test search and filter logic
- Test date formatting utilities
- Test statistics calculations

### Integration Tests
- Test AdminService integration
- Test dialog interactions
- Test data persistence

### UI Tests
- Test responsive layout
- Test button interactions
- Test error handling UI

## Troubleshooting

### Common Issues

**Issue**: "No donors found"
- *Solution*: Ensure Firestore has donor data, check `blood_donors` collection exists

**Issue**: Updates not reflecting immediately
- *Solution*: Data refreshes on screen reload, consider adding `_loadDonors()` after updates

**Issue**: Search results empty
- *Solution*: Verify search text matches donor data exactly, search is case-insensitive for names

## Support

For issues or feature requests, please refer to the main ResQnow Admin Dashboard documentation.
