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
import 'theme/app_theme.dart';
import 'utils/toast_util.dart';

void main() {
  // 初始化API服务
  initApiService();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => WithdrawalProvider()),
        ChangeNotifierProvider(create: (_) => BillProvider()),
      ],
      child: const MyApp(),
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