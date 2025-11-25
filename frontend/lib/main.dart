import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'config/router.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/withdrawal_provider.dart';
import 'providers/bill_provider.dart';
import 'providers/user_provider.dart';
import 'services/api_service.dart';
import 'services/web_platform_service.dart';
import 'theme/app_theme.dart';
import 'utils/toast_util.dart';
import 'utils/error_handler.dart';

Future<void> main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化全局异常处理
  GlobalExceptionHandler.initialize();
  
  // 初始化API服务
  initApiService();
  
  // Web平台特定初始化
  if (kIsWeb) {
    await WebPlatformService().initialize();
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (_) => UserProvider(),
          update: (_, authProvider, userProvider) {
            // 当AuthProvider更新时，同步更新UserProvider
            if (userProvider == null) {
              return UserProvider();
            }
            if (authProvider.userInfo != null) {
              userProvider.setCurrentUser(authProvider.userInfo!);
            } else {
              userProvider.clearCurrentUser();
            }
            return userProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => WithdrawalProvider()),
        ChangeNotifierProvider(create: (_) => BillProvider()),
      ],
      child: Builder(
        builder: (context) {
          // 设置全局认证提供者引用
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          AuthProvider.globalAuthProvider = authProvider;
          
          return const MyApp();
        },
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = AppRouter.router;
    
    return MaterialApp.router(
      title: '陪玩伴侣',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: ToastUtil.scaffoldMessengerKey,
    );
  }
}