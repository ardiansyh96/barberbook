import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../customer/notification/providers/notification_provider.dart';

/// Admin screen for sending broadcast notifications to all customers.
///
/// Features:
/// - Title and body input
/// - Notification type selection (promotion, announcement)
/// - Preview before sending
/// - Shows count of customers notified
class AdminSendNotificationScreen extends ConsumerStatefulWidget {
  const AdminSendNotificationScreen({super.key});

  @override
  ConsumerState<AdminSendNotificationScreen> createState() => _AdminSendNotificationScreenState();
}

class _AdminSendNotificationScreenState extends ConsumerState<AdminSendNotificationScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String _type = 'promotion';
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    if (_titleController.text.trim().isEmpty || _bodyController.text.trim().isEmpty) {
      SnackbarHelper.error(context, 'Title and message are required');
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Send Notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${_type.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Title: ${_titleController.text.trim()}'),
            const SizedBox(height: 4),
            Text('Message: ${_bodyController.text.trim()}'),
            const SizedBox(height: 16),
            const Text('This will be sent to all registered customers.',
                style: TextStyle(color: AppColors.darkGrey, fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.white),
            child: const Text('Send'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSending = true);

    try {
      final service = ref.read(notificationServiceProvider);
      final count = await service.notifyAllCustomers(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        type: _type,
      );

      if (mounted) {
        SnackbarHelper.success(context, 'Notification sent to $count customers!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        SnackbarHelper.error(context, 'Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Send Notification'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Broadcast to All Customers',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 4),
            const Text('Send a notification to all registered customers.',
                style: TextStyle(color: AppColors.darkGrey, fontSize: 13)),
            const SizedBox(height: AppDimensions.spacingXL),

            // Notification type
            const Text('Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTypeChip('Promotion', 'promotion'),
                const SizedBox(width: 8),
                _buildTypeChip('Announcement', 'announcement'),
                const SizedBox(width: 8),
                _buildTypeChip('Update', 'update'),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingXL),

            CustomTextField(
              controller: _titleController,
              label: 'Title',
              hintText: 'Notification title',
              prefixIcon: Icons.title,
            ),
            const SizedBox(height: AppDimensions.spacingLG),

            CustomTextField(
              controller: _bodyController,
              label: 'Message',
              hintText: 'Notification message body',
              prefixIcon: Icons.message,
              maxLines: 4,
            ),
            const SizedBox(height: AppDimensions.spacingXXL),

            // Preview
            if (_titleController.text.isNotEmpty || _bodyController.text.isNotEmpty) ...[
              const Text('Preview', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingLG),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                  border: Border.all(color: AppColors.mediumGrey),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.notifications, color: AppColors.gold, size: 20),
                    ),
                    const SizedBox(width: AppDimensions.spacingMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_titleController.text.trim().isEmpty ? 'Title...' : _titleController.text.trim(),
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(
                            _bodyController.text.trim().isEmpty ? 'Message...' : _bodyController.text.trim(),
                            style: const TextStyle(color: AppColors.darkGrey, fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXL),
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSending ? null : _sendNotification,
                icon: _isSending
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                    : const Icon(Icons.send),
                label: Text(_isSending ? 'Sending...' : 'Send Notification'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, String value) {
    final isSelected = _type == value;
    return GestureDetector(
      onTap: () => setState(() => _type = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.gold : AppColors.mediumGrey),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.charcoal,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
