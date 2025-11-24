import 'package:flutter/material.dart';
import '../../services/test_service.dart';
import '../../utils/toast_util.dart';

class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  bool _isLoading = false;
  String _result = '';

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final result = await TestService.testConnection();
      setState(() {
        _result = '连接测试成功:\n${result.toString()}';
      });
      ToastUtil.showSuccess('API连接成功');
    } catch (e) {
      setState(() {
        _result = '连接测试失败:\n$e';
      });
      ToastUtil.showError('API连接失败');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testHello() async {
    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final result = await TestService.testHello();
      setState(() {
        _result = 'Hello测试成功:\n${result.toString()}';
      });
      ToastUtil.showSuccess('Hello API成功');
    } catch (e) {
      setState(() {
        _result = 'Hello测试失败:\n$e';
      });
      ToastUtil.showError('Hello API失败');
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
        title: const Text('API测试'),
        actions: [
          Switch(
            value: TestService.isMockMode,
            onChanged: (value) {
              TestService.setMockMode(value);
              setState(() {});
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '当前模式: ${TestService.isMockMode ? '模拟数据' : '真实API'}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testConnection,
                    child: const Text('测试连接'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testHello,
                    child: const Text('测试Hello'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_result.isNotEmpty)
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _result,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}