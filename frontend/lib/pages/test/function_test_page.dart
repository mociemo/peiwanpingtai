import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class FunctionTestPage extends StatefulWidget {
  const FunctionTestPage({super.key});

  @override
  State<FunctionTestPage> createState() => _FunctionTestPageState();
}

class _FunctionTestPageState extends State<FunctionTestPage> {
  bool _isLoading = false;
  String _testResult = '';

  Future<void> _testAPI(String testName, Future<void> Function() testFunction) async {
    setState(() {
      _isLoading = true;
      _testResult = '正在测试 $testName...';
    });

    try {
      await testFunction();
      setState(() {
        _testResult = '✅ $testName - 测试通过';
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ $testName - 测试失败: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('功能测试'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // API连接测试
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'API连接测试',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : () => _testAPI(
                        '获取用户信息',
                        () async {
                          final response = await ApiService.getUserInfo();
                          if (response['success'] != true) {
                            throw Exception('获取用户信息失败');
                          }
                        },
                      ),
                      child: const Text('测试获取用户信息'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : () => _testAPI(
                        '获取订单列表',
                        () async {
                          final response = await ApiService.getUserOrders();
                          if (response['success'] != true) {
                            throw Exception('获取订单列表失败');
                          }
                        },
                      ),
                      child: const Text('测试获取订单列表'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 页面导航测试
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '页面导航测试',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: () => context.push('/home'),
                          child: const Text('首页'),
                        ),
                        ElevatedButton(
                          onPressed: () => context.push('/profile'),
                          child: const Text('个人资料'),
                        ),
                        ElevatedButton(
                          onPressed: () => context.push('/orders'),
                          child: const Text('订单'),
                        ),
                        ElevatedButton(
                          onPressed: () => context.push('/community/posts'),
                          child: const Text('社区'),
                        ),
                        ElevatedButton(
                          onPressed: () => context.push('/chat/conversations'),
                          child: const Text('聊天'),
                        ),
                        ElevatedButton(
                          onPressed: () => context.push('/payment/recharge'),
                          child: const Text('充值'),
                        ),
                        ElevatedButton(
                          onPressed: () => context.push('/search'),
                          child: const Text('搜索'),
                        ),
                        ElevatedButton(
                          onPressed: () => context.push('/settings'),
                          child: const Text('设置'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 认证功能测试
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '认证功能测试',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _testLogin,
                      child: const Text('测试登录'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (!mounted) return;
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        authProvider.logout();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('已退出登录')),
                          );
                        }
                      },
                      child: const Text('退出登录'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 测试结果显示
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '测试结果',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      Text(
                        _testResult.isEmpty ? '请选择测试项目' : _testResult,
                        style: const TextStyle(fontSize: 16),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testLogin() async {
    await _testAPI(
      '登录测试',
      () async {
        final response = await ApiService.login('testuser', 'password');
        if (response['token'] == null) {
          throw Exception('登录失败，未获取到token');
        }
        // 更新认证状态
        if (!mounted) return;
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.login('testuser', 'password');
      },
    );
  }
}