import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hakkında'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppInfo(context),
              SizedBox(height: 24.h),
              _buildFeaturesList(context),
              SizedBox(height: 24.h),
              _buildDeveloperInfo(context),
              SizedBox(height: 24.h),
              _buildLegalInfo(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfo(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.apartment,
              size: 60.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'SmartCommunityAI',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 8.h),
          Text(
            'Sürüm 1.0.0',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Akıllı site yönetim uygulaması',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    final features = [
      {
        'icon': Icons.payment,
        'title': 'Aidat Ödemeleri',
        'description': 'Kolay ve güvenli aidat ödeme sistemi',
      },
      {
        'icon': Icons.announcement,
        'title': 'Duyurular',
        'description': 'Site yönetiminden gelen önemli duyurular',
      },
      {
        'icon': Icons.report_problem,
        'title': 'Arıza Bildirimi',
        'description': 'Hızlı arıza bildirimi ve takibi',
      },
      {
        'icon': Icons.message,
        'title': 'Mesajlaşma',
        'description': 'Site yönetimi ile doğrudan iletişim',
      },
      {
        'icon': Icons.poll,
        'title': 'Anketler',
        'description': 'Site sakinlerinin görüşlerini alma',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Özellikler',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 16.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return ListTile(
              leading: Icon(
                feature['icon'] as IconData,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(feature['title'] as String),
              subtitle: Text(feature['description'] as String),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDeveloperInfo(BuildContext context) {
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
              'Geliştirici Bilgileri',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Icon(
                  Icons.business,
                  size: 24.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SmartCommunityAI Technologies',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Akıllı yaşam çözümleri geliştiren teknoloji şirketi',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Icon(
                  Icons.language,
                  size: 24.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Web Sitesi',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'www.smartcommunityai.com',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Icon(
                  Icons.email,
                  size: 24.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'İletişim',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'info@smartcommunityai.com',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Yasal Bilgiler',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 16.h),
        Card(
          margin: EdgeInsets.only(bottom: 8.h),
          child: ListTile(
            leading: Icon(
              Icons.description,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Kullanım Koşulları'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to terms of service
            },
          ),
        ),
        Card(
          margin: EdgeInsets.only(bottom: 8.h),
          child: ListTile(
            leading: Icon(
              Icons.privacy_tip,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Gizlilik Politikası'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to privacy policy
            },
          ),
        ),
        Card(
          margin: EdgeInsets.only(bottom: 8.h),
          child: ListTile(
            leading: Icon(
              Icons.verified_user,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Lisans Bilgileri'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to license information
            },
          ),
        ),
      ],
    );
  }
} 