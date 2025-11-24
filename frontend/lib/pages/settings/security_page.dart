import 'package:flutter/material.dart';

import '../../widgets/custom_button.dart';
import '../../utils/toast_util.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  
  bool _isLoading = false;
  bool _showPasswordForm = false;
  bool _showPhoneForm = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
 
      await Future.delayed(const Duration(seconds: 1));
      
      ToastUtil.showSuccess('密码修改成功');
      _clearPasswordForm();
    } catch (e) {
      ToastUtil.showError('密码修改失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _bindPhone() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      ToastUtil.showSuccess('手机号绑定成功');
      _clearPhoneForm();
    } catch (e) {
      ToastUtil.showError('手机号绑定失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendVerificationCode() async {
    if (_phoneController.text.isEmpty) {
      ToastUtil.showError('请输入手机号');
      return;
    }

    try {
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      ToastUtil.showSuccess('验证码已发送');
    } catch (e) {
      ToastUtil.showError('发送验证码失败: $e');
    }
  }

  void _clearPasswordForm() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    setState(() => _showPasswordForm = false);
  }

  void _clearPhoneForm() {
    _phoneController.clear();
    _verificationCodeController.clear();
    setState(() => _showPhoneForm = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('账户安全'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 修改密码
            _buildSecuritySection(
              title: '修改密码',
              icon: Icons.lock,
              onTap: () => setState(() => _showPasswordForm = !_showPasswordForm),
              child: _showPasswordForm ? _buildPasswordForm() : null,
            ),
            
            const SizedBox(height: 16),
            
            // 绑定手机
            _buildSecuritySection(
              title: '绑定手机',
              icon: Icons.phone,
              onTap: () => setState(() => _showPhoneForm = !_showPhoneForm),
              child: _showPhoneForm ? _buildPhoneForm() : null,
            ),
            
            const SizedBox(height: 16),
            
            // 登录记录
            _buildSecuritySection(
              title: '登录记录',
              icon: Icons.history,
              onTap: () => _showLoginRecords(),
              child: null,
            ),
            
            const SizedBox(height: 16),
            
            // 设备管理
            _buildSecuritySection(
              title: '设备管理',
              icon: Icons.devices,
              onTap: () => _showDeviceManagement(),
              child: null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Widget? child,
  }) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon),
            title: Text(title),
            trailing: child != null 
                ? const Icon(Icons.expand_less)
                : const Icon(Icons.chevron_right),
            onTap: onTap,
          ),
          if (child != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPasswordForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _currentPasswordController,
            decoration: const InputDecoration(
              labelText: '当前密码',
              hintText: '请输入当前密码',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入当前密码';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _newPasswordController,
            decoration: const InputDecoration(
              labelText: '新密码',
              hintText: '请输入新密码',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入新密码';
              }
              if (value.length < 6) {
                return '密码长度不能少于6位';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            decoration: const InputDecoration(
              labelText: '确认新密码',
              hintText: '请确认新密码',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请确认新密码';
              }
              if (value != _newPasswordController.text) {
                return '两次输入的密码不一致';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearPasswordForm,
                  child: const Text('取消'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: '确认修改',
                  onPressed: _changePassword,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: '手机号',
              hintText: '请输入手机号',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入手机号';
              }
              if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
                return '请输入正确的手机号';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _verificationCodeController,
                  decoration: const InputDecoration(
                    labelText: '验证码',
                    hintText: '请输入验证码',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入验证码';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _sendVerificationCode,
                child: const Text('发送验证码'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearPhoneForm,
                  child: const Text('取消'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: '确认绑定',
                  onPressed: _bindPhone,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLoginRecords() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('登录记录'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildLoginRecordItem(
                '2024-11-23 14:30:25',
                'Windows PC',
                '192.168.1.100',
                '北京市',
              ),
              _buildLoginRecordItem(
                '2024-11-23 08:15:10',
                'Android',
                '192.168.1.101',
                '北京市',
              ),
              _buildLoginRecordItem(
                '2024-11-22 20:45:33',
                'iOS',
                '192.168.1.102',
                '北京市',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginRecordItem(String time, String device, String ip, String location) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          device.contains('Windows') ? Icons.computer :
          device.contains('Android') ? Icons.phone_android :
          Icons.phone_iphone,
        ),
        title: Text(device),
        subtitle: Text('$time\n$ip - $location'),
        isThreeLine: true,
      ),
    );
  }

  void _showDeviceManagement() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设备管理'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildDeviceItem(
                'Windows PC',
                '当前设备',
                '最近登录: 2024-11-23 14:30',
                true,
              ),
              _buildDeviceItem(
                'Android 手机',
                'Xiaomi 13',
                '最近登录: 2024-11-23 08:15',
                false,
              ),
              _buildDeviceItem(
                'iPhone 15',
                'iOS 17.0',
                '最近登录: 2024-11-22 20:45',
                false,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceItem(String deviceName, String deviceInfo, String lastLogin, bool isCurrent) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          deviceName.contains('Windows') ? Icons.computer :
          deviceName.contains('Android') ? Icons.phone_android :
          Icons.phone_iphone,
        ),
        title: Text(deviceName),
        subtitle: Text('$deviceInfo\n$lastLogin'),
        isThreeLine: true,
        trailing: isCurrent 
          ? const Chip(
              label: Text('当前设备'),
              backgroundColor: Colors.green,
              labelStyle: TextStyle(color: Colors.white),
            )
          : IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('移除设备'),
                    content: Text('确定要移除设备 $deviceName 吗？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ToastUtil.showSuccess('设备已移除');
                        },
                        child: const Text('确定'),
                      ),
                    ],
                  ),
                );
              },
            ),
      ),
    );
  }
}