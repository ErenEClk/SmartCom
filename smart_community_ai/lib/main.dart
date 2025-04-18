import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:smart_community_ai/core/providers/auth_provider.dart';
import 'package:smart_community_ai/core/providers/theme_provider.dart';
import 'package:smart_community_ai/core/providers/announcement_provider.dart';
import 'package:smart_community_ai/core/providers/issue_provider.dart';
import 'package:smart_community_ai/core/providers/notification_provider.dart';
import 'package:smart_community_ai/core/providers/payment_provider.dart';
import 'package:smart_community_ai/core/providers/messaging_provider.dart';
import 'package:smart_community_ai/core/providers/user_provider.dart';
import 'package:smart_community_ai/core/services/api_service.dart';
import 'package:smart_community_ai/core/services/auth_service.dart';
import 'package:smart_community_ai/core/utils/app_routes.dart';
import 'package:smart_community_ai/core/utils/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_community_ai/features/admin/screens/admin_dashboard_screen.dart';
import 'package:smart_community_ai/features/auth/screens/login_screen.dart';
import 'package:smart_community_ai/features/dashboard/screens/dashboard_screen.dart';
import 'package:smart_community_ai/features/splash/screens/splash_screen.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:smart_community_ai/core/providers/survey_provider.dart';
import 'package:smart_community_ai/core/constants/api_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Tarih formatlaması için Türkçe yerelleştirmeyi başlat
    await initializeDateFormatting('tr_TR', null);
    
    // .env dosyasını yüklemeyi dene, bulunamazsa devam et
    try {
      // Birden fazla konumda .env dosyasını aramayı deneyelim
      bool loaded = false;
      
      try {
        await dotenv.load(fileName: ".env");
        loaded = true;
        print(".env dosyası ana dizinden başarıyla yüklendi");
      } catch (e) {
        print("Ana dizindeki .env dosyası yüklenemedi: $e");
      }
      
      if (!loaded) {
        try {
          await dotenv.load(fileName: "assets/.env");
          loaded = true;
          print(".env dosyası assets/ dizininden başarıyla yüklendi");
        } catch (e) {
          print("assets/ dizinindeki .env dosyası yüklenemedi: $e");
        }
      }
      
      if (loaded) {
        print("API URL: ${dotenv.env['API_URL']}");
        print("Test Modu: ${dotenv.env['IS_TEST_MODE']}");
      } else {
        print(".env dosyası hiçbir konumda bulunamadı, varsayılan değerler kullanılacak");
      }
    } catch (e) {
      print("Dotenv yükleme hatası: $e");
      print(".env dosyası bulunamadı, varsayılan değerler kullanılacak");
    }
    
    print("Uygulama başlatılıyor...");
    runApp(const MyApp());
  } catch (e) {
    print("Uygulama başlatma hatası: $e");
    // Basit bir hata ekranı göster
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text("Uygulama başlatılırken hata oluştu: $e"),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("MyApp build metodu çalıştı");
    
    // API URL ve test modu değerini doğrudan ApiConstants üzerinden al
    final apiUrl = ApiConstants.baseUrl;
    final isTestMode = ApiConstants.isTestMode;
    
    print("API URL: $apiUrl");
    print("Test Modu: $isTestMode");
    
    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) {
            print("ApiService oluşturuluyor");
            return ApiService(baseUrl: apiUrl);
          },
        ),
        Provider<AuthService>(
          create: (_) {
            print("AuthService oluşturuluyor");
            return AuthService();
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            print("ThemeProvider oluşturuluyor");
            return ThemeProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            print("AuthProvider oluşturuluyor");
            return AuthProvider(
              apiService: context.read<ApiService>(),
              isTestMode: isTestMode,
            );
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            print("PaymentProvider oluşturuluyor");
            return PaymentProvider(
              apiService: context.read<ApiService>(),
              isTestMode: isTestMode,
            );
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            print("AnnouncementProvider oluşturuluyor");
            return AnnouncementProvider(
              apiService: context.read<ApiService>(),
              isTestMode: isTestMode,
            );
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            print("NotificationProvider oluşturuluyor");
            return NotificationProvider(
              apiService: context.read<ApiService>(),
              isTestMode: isTestMode,
            );
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            print("IssueProvider oluşturuluyor");
            return IssueProvider(
              apiService: context.read<ApiService>(),
              isTestMode: isTestMode,
            );
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            print("SurveyProvider oluşturuluyor");
            return SurveyProvider(
              apiService: context.read<ApiService>(),
              isTestMode: isTestMode,
            );
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            print("MessagingProvider oluşturuluyor");
            return MessagingProvider(
              apiService: context.read<ApiService>(),
              authService: context.read<AuthService>(),
            );
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            print("UserProvider oluşturuluyor");
            return UserProvider(
              authService: context.read<AuthService>(),
            );
          },
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          print("ScreenUtilInit builder çalıştı");
          return MaterialApp(
            title: 'Akıllı Site',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routes: AppRoutes.getRoutes(),
            onGenerateRoute: AppRoutes.generateRoute,
            // Home özelliği kaldırıldı, routes kullanılacak
            initialRoute: '/login',
          );
        },
      ),
    );
  }
}
