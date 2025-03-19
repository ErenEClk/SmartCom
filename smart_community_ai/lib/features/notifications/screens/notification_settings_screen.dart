import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // Bildirim ayarları
  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _smsNotificationsEnabled = false;

  // Bildirim kategorileri
  Map<String, bool> _notificationCategories = {
    'payments': true,
    'announcements': true,
    'issues': true,
    'surveys': true,
    'messages': true,
    'maintenance': true,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirim Ayarları'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNotificationChannels(),
              SizedBox(height: 24.h),
              _buildNotificationCategories(),
              SizedBox(height: 24.h),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationChannels() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bildirim Kanalları',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16.h),
            _buildSwitchTile(
              title: 'Anlık Bildirimler',
              subtitle: 'Telefonunuza anlık bildirimler alın',
              value: _pushNotificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _pushNotificationsEnabled = value;
                });
              },
            ),
            Divider(height: 1),
            _buildSwitchTile(
              title: 'E-posta Bildirimleri',
              subtitle: 'E-posta adresinize bildirimler alın',
              value: _emailNotificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _emailNotificationsEnabled = value;
                });
              },
            ),
            Divider(height: 1),
            _buildSwitchTile(
              title: 'SMS Bildirimleri',
              subtitle: 'Telefonunuza SMS bildirimleri alın',
              value: _smsNotificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _smsNotificationsEnabled = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCategories() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bildirim Kategorileri',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16.h),
            _buildCategorySwitchTile(
              title: 'Ödemeler',
              subtitle: 'Aidat ve diğer ödemelerle ilgili bildirimler',
              category: 'payments',
            ),
            Divider(height: 1),
            _buildCategorySwitchTile(
              title: 'Duyurular',
              subtitle: 'Site yönetiminden gelen duyurular',
              category: 'announcements',
            ),
            Divider(height: 1),
            _buildCategorySwitchTile(
              title: 'Arıza Bildirimleri',
              subtitle: 'Arıza bildirimlerinizle ilgili güncellemeler',
              category: 'issues',
            ),
            Divider(height: 1),
            _buildCategorySwitchTile(
              title: 'Anketler',
              subtitle: 'Yeni anketler ve anket sonuçları',
              category: 'surveys',
            ),
            Divider(height: 1),
            _buildCategorySwitchTile(
              title: 'Mesajlar',
              subtitle: 'Site yönetiminden gelen mesajlar',
              category: 'messages',
            ),
            Divider(height: 1),
            _buildCategorySwitchTile(
              title: 'Bakım ve Onarım',
              subtitle: 'Sitede yapılacak bakım ve onarım çalışmaları',
              category: 'maintenance',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildCategorySwitchTile({
    required String title,
    required String subtitle,
    required String category,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
      ),
      value: _notificationCategories[category] ?? false,
      onChanged: (value) {
        setState(() {
          _notificationCategories[category] = value;
        });
      },
      activeColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveSettings,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12.h),
        ),
        child: const Text('Ayarları Kaydet'),
      ),
    );
  }

  void _saveSettings() {
    // TODO: Implement settings save
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bildirim ayarları kaydedildi'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }
} 