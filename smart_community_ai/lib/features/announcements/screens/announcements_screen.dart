import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duyurular'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAnnouncementsList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement announcement creation for admins
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAnnouncementsList() {
    final announcements = [
      {
        'title': 'Asansör Bakımı',
        'date': '15 Şubat 2025',
        'content': 'Değerli site sakinlerimiz, 18 Şubat Pazartesi günü saat 10:00-14:00 arasında asansörlerimizin yıllık bakımı yapılacaktır. Bu süre zarfında asansörler kullanılamayacaktır. Anlayışınız için teşekkür ederiz.',
        'isImportant': true,
      },
      {
        'title': 'Su Kesintisi',
        'date': '10 Şubat 2025',
        'content': 'Değerli site sakinlerimiz, 12 Şubat Çarşamba günü saat 09:00-13:00 arasında bölgemizde su kesintisi yaşanacaktır. Gerekli tedbirleri almanızı rica ederiz.',
        'isImportant': true,
      },
      {
        'title': 'Otopark Düzenlemesi',
        'date': '5 Şubat 2025',
        'content': 'Değerli site sakinlerimiz, artan araç sayısı nedeniyle otopark düzenlemesi yapılmıştır. Her daireye bir araçlık yer tahsis edilmiştir. Misafir araçları için ayrılan bölüme park edilmesi rica olunur.',
        'isImportant': false,
      },
      {
        'title': 'Çocuk Parkı Yenileme',
        'date': '1 Şubat 2025',
        'content': 'Değerli site sakinlerimiz, çocuk parkımız yenilenmiştir. Yeni oyun grupları eklenmiş olup, çocuklarımızın güvenli bir şekilde oynamaları için gerekli önlemler alınmıştır.',
        'isImportant': false,
      },
      {
        'title': 'Aidat Zammı',
        'date': '25 Ocak 2025',
        'content': 'Değerli site sakinlerimiz, artan giderler nedeniyle 1 Şubat 2025 tarihinden itibaren aidat miktarı %10 oranında artırılmıştır. Anlayışınız için teşekkür ederiz.',
        'isImportant': true,
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: announcements.length,
      itemBuilder: (context, index) {
        final announcement = announcements[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: announcement['isImportant'] as bool
                ? BorderSide(color: Colors.red, width: 1.5)
                : BorderSide.none,
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (announcement['isImportant'] as bool)
                      Icon(
                        Icons.priority_high,
                        color: Colors.red,
                        size: 20.sp,
                      ),
                    Expanded(
                      child: Text(
                        announcement['title'] as String,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  announcement['date'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                SizedBox(height: 12.h),
                Text(
                  announcement['content'] as String,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Implement share functionality
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Paylaş'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 