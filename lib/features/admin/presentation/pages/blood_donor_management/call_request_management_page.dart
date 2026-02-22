import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resqnow_admin/core/services/admin_service.dart';

/// Call Request Management Page for Admins
class CallRequestManagementPage extends StatefulWidget {
  const CallRequestManagementPage({Key? key}) : super(key: key);

  @override
  State<CallRequestManagementPage> createState() =>
      _CallRequestManagementPageState();
}

class _CallRequestManagementPageState extends State<CallRequestManagementPage> {
  late AdminService _adminService;
  bool _isLoading = false;
  String _selectedStatus =
      'pending'; // Filter by status: 'pending', 'approved', 'rejected', 'all'

  @override
  void initState() {
    super.initState();
    _adminService = AdminService(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Request Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 4,
      ),
      body: Column(
        children: [
          // Status Filter Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatusFilterChip('pending', 'Pending'),
                  const SizedBox(width: 8),
                  _buildStatusFilterChip('approved', 'Approved'),
                  const SizedBox(width: 8),
                  _buildStatusFilterChip('rejected', 'Rejected'),
                  const SizedBox(width: 8),
                  _buildStatusFilterChip('all', 'All'),
                ],
              ),
            ),
          ),
          // Call Requests List
          Expanded(child: _buildCallRequestsList()),
        ],
      ),
    );
  }

  Widget _buildStatusFilterChip(String status, String label) {
    return FilterChip(
      label: Text(label),
      selected: _selectedStatus == status,
      onSelected: (bool selected) {
        setState(() {
          if (selected) {
            _selectedStatus = status;
          }
        });
      },
    );
  }

  Widget _buildCallRequestsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getCallRequestsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No call requests found',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: docs.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final requestId = docs[index].id;
            return _buildCallRequestCard(context, requestId, data);
          },
        );
      },
    );
  }

  Stream<QuerySnapshot> _getCallRequestsStream() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection(
      'call_requests',
    );

    if (_selectedStatus != 'all') {
      query = query.where('status', isEqualTo: _selectedStatus);
    }

    return query.orderBy('requestedAt', descending: true).snapshots();
  }

  Widget _buildCallRequestCard(
    BuildContext context,
    String requestId,
    Map<String, dynamic> data,
  ) {
    final status = data['status'] ?? 'pending';
    final requesterName = data['requesterName'] ?? 'Unknown';
    final requesterEmail = data['requesterEmail'] ?? 'No email';
    final donorName = data['donorName'] ?? 'Unknown';
    final donorPhone = data['donorPhone'] ?? 'No phone';
    final requestedAt = (data['requestedAt'] as Timestamp?)?.toDate();
    final adminNotes = data['adminNotes'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status badge
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Request #${requestId.substring(0, 8)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        requesterName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(status),
              ],
            ),
            const SizedBox(height: 12),
            // Request details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    'Requester Email:',
                    requesterEmail,
                    Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow('Donor:', donorName, Colors.green),
                  const SizedBox(height: 8),
                  _buildDetailRow('Donor Phone:', donorPhone, Colors.orange),
                  if (requestedAt != null) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Requested At:',
                      '${requestedAt.day}/${requestedAt.month}/${requestedAt.year} ${requestedAt.hour}:${requestedAt.minute.toString().padLeft(2, '0')}',
                      Colors.purple,
                    ),
                  ],
                  if (adminNotes != null && adminNotes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow('Admin Notes:', adminNotes, Colors.red),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Action buttons
            if (status == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _approveCallRequest(context, requestId),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _rejectCallRequest(context, requestId),
                    ),
                  ),
                ],
              ),
            ] else if (status == 'approved') ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This request has been approved. The donor and requester can now connect.',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (status == 'rejected') ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This request has been rejected.',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        break;
      case 'approved':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w600, color: color),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Future<void> _approveCallRequest(
    BuildContext context,
    String requestId,
  ) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Call Request?'),
        content: const Text(
          'This will notify the user that their call request has been approved. They will be able to contact the donor directly.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      // Use AdminService to approve and create notification
      await _adminService.approveCallRequest(requestId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Call request approved successfully. User notified.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error approving request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _rejectCallRequest(
    BuildContext context,
    String requestId,
  ) async {
    final notesController = TextEditingController();

    // Show rejection dialog with notes
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Call Request?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please provide a reason for rejection:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter rejection reason...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final reason = notesController.text.isNotEmpty
          ? notesController.text
          : 'Request rejected by admin';

      // Use AdminService to reject and create notification
      await _adminService.rejectCallRequest(requestId, reason);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Call request rejected successfully. User notified.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error rejecting request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
