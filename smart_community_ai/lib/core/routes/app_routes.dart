import 'package:flutter/material.dart';
import 'package:smart_community_ai/features/admin/screens/admin_dashboard_screen.dart';
import 'package:smart_community_ai/features/admin/screens/admin_issue_detail_screen.dart';
import 'package:smart_community_ai/features/admin/screens/admin_issues_screen.dart';
import 'package:smart_community_ai/features/admin/screens/admin_messaging_screen.dart';
import 'package:smart_community_ai/features/auth/screens/forgot_password_screen.dart';
import 'package:smart_community_ai/features/auth/screens/login_screen.dart';
import 'package:smart_community_ai/features/auth/screens/register_screen.dart';
import 'package:smart_community_ai/features/dashboard/screens/dashboard_screen.dart';
import 'package:smart_community_ai/features/issues/screens/create_issue_screen.dart';
import 'package:smart_community_ai/features/issues/screens/issue_detail_screen.dart';
import 'package:smart_community_ai/features/issues/screens/issues_screen.dart';
import 'package:smart_community_ai/features/messaging/screens/messaging_screen.dart';
import 'package:smart_community_ai/features/payments/screens/payment_detail_screen.dart';
import 'package:smart_community_ai/features/payments/screens/payment_screen.dart';
import 'package:smart_community_ai/features/profile/screens/profile_screen.dart';
import 'package:smart_community_ai/features/splash/screens/splash_screen.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case SplashScreen.routeName:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case LoginScreen.routeName:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case RegisterScreen.routeName:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
      case ForgotPasswordScreen.routeName:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      
      case DashboardScreen.routeName:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      
      case ProfileScreen.routeName:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      
      case PaymentScreen.routeName:
        return MaterialPageRoute(builder: (_) => const PaymentScreen());
      
      case PaymentDetailScreen.routeName:
        final String paymentId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => PaymentDetailScreen(paymentId: paymentId),
        );
      
      case IssuesScreen.routeName:
        return MaterialPageRoute(builder: (_) => const IssuesScreen());
      
      case CreateIssueScreen.routeName:
        return MaterialPageRoute(builder: (_) => const CreateIssueScreen());
      
      case IssueDetailScreen.routeName:
        final String issueId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => IssueDetailScreen(issueId: issueId),
        );
      
      case AdminDashboardScreen.routeName:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      
      case AdminIssuesScreen.routeName:
        return MaterialPageRoute(builder: (_) => const AdminIssuesScreen());
      
      case AdminMessagingScreen.routeName:
        return MaterialPageRoute(builder: (_) => const AdminMessagingScreen());
      
      case MessagingScreen.routeName:
        return MaterialPageRoute(builder: (_) => const MessagingScreen());
      
      case '/admin-issue-detail':
        final String issueId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => AdminIssueDetailScreen(issueId: issueId),
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