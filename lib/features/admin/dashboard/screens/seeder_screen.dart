import 'package:flutter/material.dart';
import '../../../../core/utils/firestore_seeder.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Admin screen for running Firestore seeder.
///
/// This screen provides a UI to populate initial data in Firestore.
/// It should only be used once during initial setup.
class SeederScreen extends StatefulWidget {
  const SeederScreen({super.key});

  @override
  State<SeederScreen> createState() => _SeederScreenState();
}

class _SeederScreenState extends State<SeederScreen> {
  bool _isSeeding = false;
  SeedResult? _result;

  Future<void> _runSeeder() async {
    setState(() {
      _isSeeding = true;
      _result = null;
    });

    try {
      final result = await FirestoreSeeder.seed();
      setState(() {
        _result = result;
        _isSeeding = false;
      });

      if (result.success) {
        _showSuccessDialog();
      } else {
        _showErrorDialog(result.message);
      }
    } catch (e) {
      setState(() {
        _isSeeding = false;
        _result = SeedResult(
          success: false,
          message: 'Unexpected error: $e',
        );
      });
      _showErrorDialog(e.toString());
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.successGreen),
            SizedBox(width: 8),
            Text('Seeder Success!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Data has been successfully seeded:'),
            const SizedBox(height: 16),
            _buildStatRow('Barbers', _result?.barberCount ?? 0),
            _buildStatRow('Services', _result?.serviceCount ?? 0),
            _buildStatRow('Banners', _result?.bannerCount ?? 0),
            _buildStatRow('Reviews', _result?.reviewCount ?? 0),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Seeder Failed'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('• $label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Text('$count items'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Firestore Seeder'),
        backgroundColor: AppColors.primaryBlack,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingXL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Warning Card
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingLG),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange[700], size: 32),
                    const SizedBox(width: AppDimensions.spacingMD),
                    Expanded(
                      child: Text(
                        'This will populate initial data to Firestore. Only run once during setup!',
                        style: TextStyle(
                          color: Colors.orange[900],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXL),

              // Info Card
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingLG),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                  boxShadow: AppDimensions.shadowSM,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What will be seeded?',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppDimensions.spacingMD),
                    _buildInfoItem('👥', '5 Barbers', 'Professional barbers with different specialties'),
                    const SizedBox(height: 8),
                    _buildInfoItem('✂️', '10 Services', 'Various haircuts, grooming, and spa services'),
                    const SizedBox(height: 8),
                    _buildInfoItem('🖼️', '3 Banners', 'Promotional banners for customer dashboard'),
                    const SizedBox(height: 8),
                    _buildInfoItem('⭐', '5 Reviews', 'Customer reviews with ratings'),
                  ],
                ),
              ),
              const Spacer(),

              // Seed Button
              ElevatedButton(
                onPressed: _isSeeding ? null : _runSeeder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlack,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                  ),
                ),
                child: _isSeeding
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Seeding...'),
                        ],
                      )
                    : const Text(
                        'Run Seeder',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
              const SizedBox(height: AppDimensions.spacingMD),

              // Result Status
              if (_result != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingMD),
                  decoration: BoxDecoration(
                    color: _result!.success
                        ? AppColors.successGreen.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _result!.success ? Icons.check_circle : Icons.error,
                        color: _result!.success
                            ? AppColors.successGreen
                            : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _result!.message,
                          style: TextStyle(
                            color: _result!.success
                                ? AppColors.successGreen
                                : Colors.red,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Widget _buildInfoItem(String icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: AppColors.darkGrey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
