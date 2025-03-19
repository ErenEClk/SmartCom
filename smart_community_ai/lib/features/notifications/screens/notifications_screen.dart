import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:smart_community_ai/core/providers/notification_provider.dart';
import 'package:smart_community_ai/core/models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  Future<void> _loadNotifications() async {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    await notificationProvider.fetchNotifications();
  }

  void _markAsRead(String id) {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    notificationProvider.markAsRead(id);
  }

  void _markAllAsRead() {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    notificationProvider.markAllAsRead();
  }

  void _deleteNotification(String id) {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    notificationProvider.deleteNotification(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Tümünü Okundu İşaretle',
            onPressed: _markAllAsRead,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tümü'),
            Tab(text: 'Duyurular'),
            Tab(text: 'Ödemeler'),
            Tab(text: 'Diğer'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationList(null),
          _buildNotificationList('announcement'),
          _buildNotificationList('payment'),
          _buildNotificationList('other'),
        ],
      ),
    );
  }

  Widget _buildNotificationList(String? type) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        if (notificationProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<NotificationModel> filteredNotifications;
        if (type == null) {
          // Tümü
          filteredNotifications = notificationProvider.notifications;
        } else if (type == 'other') {
          // Diğer (payment ve announcement dışındakiler)
          filteredNotifications = notificationProvider.notifications.where(
            (notification) => notification.type != 'payment' && notification.type != 'announcement',
          ).toList();
        } else {
          // Belirli bir tür
          filteredNotifications = notificationProvider.getNotificationsByType(type);
        }

        if (filteredNotifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off,
                  size: 64.sp,
                  color: Colors.grey,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Bildirim bulunmamaktadır',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadNotifications,
          child: ListView.builder(
            padding: EdgeInsets.all(8.w),
            itemCount: filteredNotifications.length,
            itemBuilder: (context, index) {
              final notification = filteredNotifications[index];
              return _buildNotificationItem(notification);
            },
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    final bool isRead = notification.isRead;
    final String type = notification.type;

    IconData iconData;
    Color iconColor;

    switch (type) {
      case 'payment':
        iconData = Icons.payment;
        iconColor = Colors.green;
        break;
      case 'announcement':
        iconData = Icons.announcement;
        iconColor = Colors.blue;
        break;
      case 'issue':
        iconData = Icons.report_problem;
        iconColor = Colors.orange;
        break;
      case 'survey':
        iconData = Icons.poll;
        iconColor = Colors.purple;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Theme.of(context).colorScheme.primary;
    }

    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16.w),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteNotification(notification.id);
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
        color: isRead ? null : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.2),
            child: Icon(
              iconData,
              color: iconColor,
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4.h),
              Text(
                notification.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              Text(
                '${notification.date} - ${notification.time}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
          isThreeLine: true,
          onTap: () {
            _markAsRead(notification.id);
            _showNotificationDetails(notification);
          },
        ),
      ),
    );
  }

  void _showNotificationDetails(NotificationModel notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.w),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      notification.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                '${notification.date} - ${notification.time}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              SizedBox(height: 16.h),
              Divider(),
              SizedBox(height: 16.h),
              Text(
                notification.message,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 24.h),
              if (notification.type == 'payment')
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Ödeme detaylarına git
                  },
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('Ödeme Detaylarını Görüntüle'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48.h),
                  ),
                )
              else if (notification.type == 'announcement')
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Duyuru detaylarına git
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('Duyuruyu Görüntüle'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48.h),
                  ),
                )
              else if (notification.type == 'issue')
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Arıza detaylarına git
                  },
                  icon: const Icon(Icons.build),
                  label: const Text('Arıza Durumunu Görüntüle'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48.h),
                  ),
                )
              else if (notification.type == 'survey')
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Anket detaylarına git
                  },
                  icon: const Icon(Icons.how_to_vote),
                  label: const Text('Ankete Katıl'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48.h),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
} 