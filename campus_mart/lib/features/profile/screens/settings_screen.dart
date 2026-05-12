import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../app/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailAlerts = false;

  void _showEditProfile(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone);
    final collegeController = TextEditingController(text: user.college);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true, // Show ABOVE the persistent Plus button
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light ? Colors.white : AppTheme.darkSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: collegeController,
              decoration: const InputDecoration(labelText: 'College/Campus'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  final success = await auth.updateProfile(
                    name: nameController.text,
                    phone: phoneController.text,
                    college: collegeController.text,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content, IconData icon) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true, // Show ABOVE the persistent Plus button
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light ? Colors.white : AppTheme.darkCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.w900, 
                letterSpacing: -0.5,
                color: Theme.of(context).brightness == Brightness.light 
                    ? AppTheme.primaryColor 
                    : Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              content,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16, 
                color: Theme.of(context).brightness == Brightness.light 
                    ? const Color(0xFF406367) 
                    : Colors.white.withOpacity(0.8), 
                height: 1.5
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it!'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true, // Show ABOVE the persistent Plus button
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Notifications', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('Manage how you receive alerts', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Receive alerts for new messages'),
                value: _pushNotifications,
                onChanged: (v) {
                  setModalState(() => _pushNotifications = v);
                  setState(() => _pushNotifications = v);
                },
                activeColor: AppTheme.primaryColor,
              ),
              SwitchListTile(
                title: const Text('Email Alerts', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Daily summary of activity'),
                value: _emailAlerts,
                onChanged: (v) {
                  setModalState(() => _emailAlerts = v);
                  setState(() => _emailAlerts = v);
                },
                activeColor: AppTheme.primaryColor,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          _SectionTitle(title: 'Account Settings'),
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () => _showEditProfile(context),
          ),
          _SettingsTile(
            icon: Icons.notifications_none,
            title: 'Notifications',
            onTap: () => _showNotificationSettings(context),
          ),
          _SettingsTile(
            icon: Icons.lock_outline,
            title: 'Privacy & Security',
            onTap: () => _showInfoDialog(context, 'Privacy & Security', 'Your data is encrypted and secure. We do not share your personal information with third parties without your consent.', Icons.verified_user_outlined),
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: 'Support & Information'),
          _SettingsTile(
            icon: Icons.help_outline,
            title: 'Help Center & Support',
            onTap: () => _showInfoDialog(context, 'Help & Technical Support', 'Our technical team is available 24/7 to assist you. Contact us at support@campusmart.com or use the real-time help feature on our website.', Icons.support_agent_rounded),
          ),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'About Campus Mart',
            onTap: () => _showInfoDialog(context, 'About Campus Mart', 'Campus Mart is a student-first marketplace designed to make buying and selling on campus easy, safe, and efficient.', Icons.auto_awesome_outlined),
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms & Conditions',
            onTap: () => _showInfoDialog(context, 'Terms & Conditions', 'By using Campus Mart, you agree to our community guidelines and terms of service. Please be respectful and honest in your dealings.', Icons.description_outlined),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Version 1.0.4 - Premium',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: Theme.of(context).primaryColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Theme.of(context).brightness == Brightness.light 
                ? AppTheme.textPrimary 
                : Colors.white,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios, 
          size: 14, 
          color: Theme.of(context).brightness == Brightness.light 
              ? AppTheme.textSecondary.withOpacity(0.3) 
              : Colors.white30
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
