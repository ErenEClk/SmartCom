import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:smart_community_ai/core/models/issue_model.dart';
import 'package:smart_community_ai/core/providers/announcement_provider.dart';
import 'package:smart_community_ai/core/providers/auth_provider.dart';
import 'package:smart_community_ai/core/providers/issue_provider.dart';
import 'package:smart_community_ai/core/providers/notification_provider.dart';
import 'package:smart_community_ai/core/providers/payment_provider.dart';
import 'package:smart_community_ai/core/utils/app_colors.dart';
import 'package:smart_community_ai/core/widgets/custom_app_bar.dart';
import 'package:smart_community_ai/features/dashboard/screens/dashboard_screen.dart';
import 'package:smart_community_ai/features/issues/screens/issue_detail_screen.dart';
import 'package:smart_community_ai/features/notifications/screens/notifications_screen.dart';
import 'package:smart_community_ai/features/messaging/screens/conversations_screen.dart';

// ... existing code ... 

Widget _buildMenuItems() {
  return GridView.count(
    crossAxisCount: 2,
    padding: const EdgeInsets.all(16),
    mainAxisSpacing: 16,
    crossAxisSpacing: 16,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    children: [
      // ... existing menu items ...
      _buildMenuItem(
        icon: Icons.chat,
        title: 'Mesajlaşma',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ConversationsScreen()),
          );
        },
      ),
      // ... existing menu items ...
    ],
  );
}

// ... existing code ... 