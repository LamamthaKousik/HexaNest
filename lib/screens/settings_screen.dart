import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../providers/patient_provider.dart';
import '../providers/visit_provider.dart';
import '../services/secure_login_service.dart';
import '../services/export_service.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../widgets/custom_card.dart';
import 'login_screen.dart';

/// Settings screen for app configuration and preferences
/// Includes language selection, PIN management, and data management
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  /// Load app version information
  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
      });
    } catch (e) {
      setState(() {
        _appVersion = 'Unknown';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryRed,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAccountSection(loginState),
                  const SizedBox(height: AppConstants.padding),
                  const SizedBox(height: AppConstants.padding),
                  _buildDataSection(),
                  const SizedBox(height: AppConstants.padding),
                  _buildAppInfoSection(),
                  const SizedBox(height: AppConstants.padding),
                  _buildDangerZoneSection(),
                ],
              ),
            ),
    );
  }

  /// Build account section
  Widget _buildAccountSection(LoginState loginState) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingTile(
            icon: Icons.lock,
            title: 'Change PIN',
            subtitle: 'Update your 4-digit PIN',
            onTap: () => _showChangePinDialog(),
          ),
          const Divider(),
          _buildSettingTile(
            icon: Icons.science,
            title: 'Practice Mode',
            subtitle: loginState.isPracticeMode ? 'Enabled' : 'Disabled',
            trailing: Switch(
              value: loginState.isPracticeMode,
              onChanged: (value) => _togglePracticeMode(),
              activeThumbColor: AppColors.primaryRed,
            ),
          ),
        ],
      ),
    );
  }


  /// Build data section
  Widget _buildDataSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Data Management',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingTile(
            icon: Icons.download,
            title: 'Export Data',
            subtitle: 'Export patients and visits as PDF/CSV',
            onTap: () => _showExportDialog(),
          ),
          const Divider(),
          _buildSettingTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Manage health reminders',
            onTap: () => _showNotificationSettings(),
          ),
        ],
      ),
    );
  }

  /// Build app info section
  Widget _buildAppInfoSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'App Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingTile(
            icon: Icons.info,
            title: 'Version',
            subtitle: _appVersion,
            onTap: null,
          ),
          const Divider(),
          _buildSettingTile(
            icon: Icons.help,
            title: 'About',
            subtitle: 'Learn more about Matru Mitra',
            onTap: () => _showAboutDialog(),
          ),
        ],
      ),
    );
  }

  /// Build danger zone section
  Widget _buildDangerZoneSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danger Zone',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingTile(
            icon: Icons.delete_forever,
            title: 'Clear All Data',
            subtitle: 'Permanently delete all patient and visit data',
            onTap: () => _showClearDataDialog(),
            textColor: Colors.red[700],
          ),
          const Divider(),
          _buildSettingTile(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of the app',
            onTap: () => _showLogoutDialog(),
            textColor: Colors.red[700],
          ),
        ],
      ),
    );
  }

  /// Build setting tile
  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? AppColors.primaryRed,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
        ),
      ),
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }

  /// Show change PIN dialog
  void _showChangePinDialog() {
    final oldPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPinController,
              decoration: const InputDecoration(
                labelText: 'Current PIN',
                hintText: 'Enter current PIN',
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPinController,
              decoration: const InputDecoration(
                labelText: 'New PIN',
                hintText: 'Enter new PIN',
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPinController,
              decoration: const InputDecoration(
                labelText: 'Confirm New PIN',
                hintText: 'Confirm new PIN',
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _changePin(
              oldPinController.text,
              newPinController.text,
              confirmPinController.text,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
            ),
            child: const Text(
              'Change PIN',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Change PIN
  Future<void> _changePin(String oldPin, String newPin, String confirmPin) async {
    if (oldPin.length != 4 || newPin.length != 4 || confirmPin.length != 4) {
      _showErrorSnackBar('PIN must be 4 digits');
      return;
    }

    if (newPin != confirmPin) {
      _showErrorSnackBar('New PINs do not match');
      return;
    }

    try {
      final success = await ref.read(loginStateProvider.notifier).changePin(oldPin, newPin);
      if (success) {
        Navigator.pop(context);
        _showSuccessSnackBar('PIN changed successfully');
      } else {
        _showErrorSnackBar('Failed to change PIN. Please check your current PIN.');
      }
    } catch (e) {
      _showErrorSnackBar('Error changing PIN: $e');
    }
  }

  /// Show export dialog
  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Choose the format for exporting your data:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _exportData('PDF');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
            ),
            child: const Text(
              'PDF',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _exportData('CSV');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
            ),
            child: const Text(
              'CSV',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Export data
  Future<void> _exportData(String format) async {
    setState(() => _isLoading = true);

    try {
      final patients = ref.read(patientProvider);
      final visits = ref.read(visitProvider);

      String? filePath;
      if (format == 'PDF') {
        filePath = await ExportService.exportComprehensiveReport(
          patients,
          visits,
          ref.read(patientStatsProvider),
        );
      } else {
        filePath = await ExportService.exportPatientsAsCSV(patients);
      }

      if (filePath != null) {
        _showSuccessSnackBar('Data exported successfully to: $filePath');
      } else {
        _showErrorSnackBar('Failed to export data');
      }
    } catch (e) {
      _showErrorSnackBar('Error exporting data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Show notification settings
  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: const Text('Notification settings will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show about dialog
  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Matru Mitra',
      applicationVersion: _appVersion,
      applicationIcon: const Icon(
        Icons.favorite,
        size: 64,
        color: AppColors.primaryRed,
      ),
      children: [
        const Text(
          'Matru Mitra is an offline-first EHR companion app designed for ASHA and PHC workers in rural India.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Features:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Text('• Patient registration and management'),
        const Text('• Visit tracking and health records'),
        const Text('• Offline data storage'),
        const Text('• Health tips and education'),
        const Text('• Multi-language support'),
        const Text('• Secure PIN-based login'),
      ],
    );
  }

  /// Show clear data dialog
  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all patient records, visit history, and app data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Clear Data',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Clear all data
  Future<void> _clearAllData() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(patientProvider.notifier).clearAllData();
      await ref.read(visitProvider.notifier).clearAllData();
      await SecureLoginService.clearAllData();
      
      _showSuccessSnackBar('All data cleared successfully');
      
      // Navigate to login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      _showErrorSnackBar('Error clearing data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Show logout dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Logout
  Future<void> _logout() async {
    try {
      await ref.read(loginStateProvider.notifier).logout();
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      _showErrorSnackBar('Error logging out: $e');
    }
  }

  /// Toggle practice mode
  Future<void> _togglePracticeMode() async {
    try {
      await ref.read(loginStateProvider.notifier).togglePracticeMode();
      _showSuccessSnackBar('Practice mode toggled');
    } catch (e) {
      _showErrorSnackBar('Error toggling practice mode: $e');
    }
  }

  /// Show success snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.synced,
      ),
    );
  }

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
