import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yardım ve Destek'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildContactCard(context),
              SizedBox(height: 24.h),
              _buildFaqSection(context),
              SizedBox(height: 24.h),
              _buildSupportRequestButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'İletişim Bilgileri',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16.h),
            _buildContactItem(
              context,
              icon: Icons.phone,
              title: 'Telefon',
              value: '+90 212 123 4567',
              onTap: () {
                // TODO: Implement phone call
              },
            ),
            Divider(height: 24.h),
            _buildContactItem(
              context,
              icon: Icons.email,
              title: 'E-posta',
              value: 'destek@smartcommunityai.com',
              onTap: () {
                // TODO: Implement email
              },
            ),
            Divider(height: 24.h),
            _buildContactItem(
              context,
              icon: Icons.location_on,
              title: 'Adres',
              value: 'Yeşil Vadi Sitesi, A Blok, No: 1, Yönetim Ofisi',
              onTap: () {
                // TODO: Implement map navigation
              },
            ),
            Divider(height: 24.h),
            _buildContactItem(
              context,
              icon: Icons.access_time,
              title: 'Çalışma Saatleri',
              value: 'Hafta içi: 09:00 - 18:00\nHafta sonu: 10:00 - 16:00',
              onTap: null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 24.sp,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: Colors.grey,
            ),
        ],
      ),
    );
  }

  Widget _buildFaqSection(BuildContext context) {
    final faqs = [
      {
        'question': 'Aidat ödememi nasıl yapabilirim?',
        'answer':
            'Aidat ödemelerinizi uygulama üzerinden "Ödemeler" bölümünden kredi kartı veya banka kartı ile yapabilirsiniz. Ayrıca havale/EFT yöntemi ile de ödeme yapabilirsiniz.',
      },
      {
        'question': 'Arıza bildirimimi nasıl takip edebilirim?',
        'answer':
            'Arıza bildirimlerinizi "Arıza Bildir" bölümünden yapabilir ve aynı bölümden takip edebilirsiniz. Ayrıca bildiriminizin durumu hakkında bildirim alacaksınız.',
      },
      {
        'question': 'Şifremi unuttum, ne yapmalıyım?',
        'answer':
            'Giriş ekranında "Şifremi Unuttum" seçeneğine tıklayarak e-posta adresinize şifre sıfırlama bağlantısı gönderebilirsiniz.',
      },
      {
        'question': 'Site yönetimine nasıl ulaşabilirim?',
        'answer':
            'Site yönetimine uygulama üzerinden "Mesaj Gönder" bölümünden mesaj gönderebilir veya yukarıdaki iletişim bilgilerini kullanarak ulaşabilirsiniz.',
      },
      {
        'question': 'Uygulamada bir hata ile karşılaştım, ne yapmalıyım?',
        'answer':
            'Uygulamada karşılaştığınız hataları aşağıdaki "Destek Talebi Oluştur" butonuna tıklayarak bildirebilirsiniz. Ekran görüntüsü eklemek sorunu daha hızlı çözmemize yardımcı olacaktır.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sık Sorulan Sorular',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 16.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: faqs.length,
          itemBuilder: (context, index) {
            return _buildFaqItem(
              context,
              question: faqs[index]['question']!,
              answer: faqs[index]['answer']!,
            );
          },
        ),
      ],
    );
  }

  Widget _buildFaqItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ExpansionTile(
        title: Text(
          question,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              answer,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportRequestButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: Implement support request
        },
        icon: const Icon(Icons.support_agent),
        label: const Text('Destek Talebi Oluştur'),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12.h),
        ),
      ),
    );
  }
} 