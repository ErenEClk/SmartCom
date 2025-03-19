import 'package:flutter/material.dart';
import 'package:smart_community_ai/features/admin/screens/admin_dashboard_screen.dart';
import 'package:smart_community_ai/features/admin/screens/admin_messaging_screen.dart';
import 'package:smart_community_ai/features/auth/screens/login_screen.dart';
import 'package:smart_community_ai/features/dashboard/screens/dashboard_screen.dart';
import 'package:smart_community_ai/features/messaging/screens/messaging_screen.dart';
import 'package:smart_community_ai/features/payments/screens/payment_screen.dart';
import 'package:smart_community_ai/features/payments/screens/payment_detail_screen.dart';
import 'package:smart_community_ai/features/splash/screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String adminDashboard = '/admin-dashboard';
  static const String adminMessaging = '/admin-messaging';
  static const String payment = '/payment';
  static const String paymentDetail = '/payment-detail';
  static const String messaging = '/messaging';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      dashboard: (context) => const DashboardScreen(),
      adminDashboard: (context) => const AdminDashboardScreen(),
      adminMessaging: (context) => const AdminMessagingScreen(),
      payment: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return PaymentScreen(paymentId: args['paymentId']);
      },
      paymentDetail: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return PaymentDetailScreen(paymentId: args['paymentId']);
      },
      messaging: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return MessagingScreen(
          contactId: args['contactId'],
          contactName: args['contactName'] ?? 'Kullanıcı',
        );
      },
    };
  }
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case adminMessaging:
        return MaterialPageRoute(builder: (_) => const AdminMessagingScreen());
      case payment:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PaymentScreen(paymentId: args['paymentId']),
        );
      case paymentDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PaymentDetailScreen(paymentId: args['paymentId']),
        );
      case messaging:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => MessagingScreen(
            contactId: args['contactId'],
            contactName: args['contactName'] ?? 'Kullanıcı',
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Sayfa bulunamadı: ${settings.name}'),
            ),
          ),
        );
    }
  }
} 