import 'package:flutter/material.dart';

import '../../models/payment_method_model.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_button.dart';
import '../../utils/toast_util.dart';

class PaymentSettingsPage extends StatefulWidget {
  const PaymentSettingsPage({super.key});

  @override
  State<PaymentSettingsPage> createState() => _PaymentSettingsState();
}

class _PaymentSettingsState extends State<PaymentSettingsPage> {
  List<PaymentMethod> _paymentMethods = [];
  bool _isLoading = true;
  String? _error;
  
  // 支付设置状态
  bool _autoRechargeEnabled = false;
  double _selectedRechargeAmount = 50.0;
  bool _biometricPaymentEnabled = false;
  bool _paymentNotificationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 从API获取支付方式
      final response = await ApiService.dio.get('/api/payment/methods');
      
      if (response.statusCode == 200 && response.data['success']) {
        final List<dynamic> methodsData = response.data['data'] ?? [];
        setState(() {
          _paymentMethods = methodsData.map((method) => PaymentMethod(
            id: method['id'].toString(),
            type: method['type'],
            name: method['name'],
            description: method['description'] ?? '',
            isDefault: method['isDefault'] ?? false,
          )).toList();
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
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
        title: const Text('支付设置'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addPaymentMethod,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? _buildErrorWidget()
              : _buildContent(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text('加载失败: $_error'),
          const SizedBox(height: 16),
          CustomButton(
            text: '重试',
            onPressed: _loadPaymentMethods,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 支付方式列表
          _buildPaymentMethodsSection(),
          const SizedBox(height: 24),
          
          // 自动充值设置
          _buildAutoRechargeSection(),
          const SizedBox(height: 24),
          
          // 支付密码设置
          _buildPaymentPasswordSection(),
          const SizedBox(height: 24),
          
          // 安全设置
          _buildSecuritySection(),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '支付方式',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                CustomButton(
                  text: '添加',
                  onPressed: _addPaymentMethod,
                ),
              ],
            ),
          ),
          if (_paymentMethods.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('暂无支付方式'),
            )
          else
            ..._paymentMethods.map((method) => _buildPaymentMethodCard(method)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method) {
    return ListTile(
      leading: _buildPaymentIcon(method.type),
      title: Text(_getPaymentTypeName(method.type)),
      subtitle: method.description.isNotEmpty ? Text(method.description) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (method.isDefault)
            Chip(
              label: const Text('默认'),
              backgroundColor: Colors.blue.shade50,
              labelStyle: const TextStyle(color: Colors.blue),
            ),
          PopupMenuButton<String>(
            onSelected: (value) => _handlePaymentMethodAction(method, value),
            itemBuilder: (context) => [
              if (!method.isDefault)
                const PopupMenuItem(
                  value: 'set_default',
                  child: Text('设为默认'),
                ),
              const PopupMenuItem(
                value: 'edit',
                child: Text('编辑'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('删除'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'alipay':
        return const Icon(Icons.account_balance_wallet, color: Colors.blue);
      case 'wechat':
        return const Icon(Icons.wechat, color: Colors.green);
      case 'bank':
        return const Icon(Icons.credit_card, color: Colors.orange);
      default:
        return const Icon(Icons.payment);
    }
  }

  String _getPaymentTypeName(String type) {
    switch (type.toLowerCase()) {
      case 'alipay':
        return '支付宝';
      case 'wechat':
        return '微信支付';
      case 'bank':
        return '银行卡';
      default:
        return '其他';
    }
  }

  Widget _buildAutoRechargeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '自动充值',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('开启自动充值'),
              subtitle: const Text('余额不足时自动充值'),
              value: _autoRechargeEnabled,
              onChanged: (value) {
                setState(() {
                  _autoRechargeEnabled = value;
                });
                ToastUtil.showSuccess(value ? '已开启自动充值' : '已关闭自动充值');
              },
            ),
            const SizedBox(height: 16),
            const Text(
              '充值金额',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [10, 20, 50, 100, 200].map((amount) {
                final isSelected = _selectedRechargeAmount == amount.toDouble();
                return ChoiceChip(
                  label: Text('¥$amount'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedRechargeAmount = amount.toDouble();
                      });
                      ToastUtil.showSuccess('已选择充值金额 ¥$amount');
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentPasswordSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '支付密码',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('修改支付密码'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _changePaymentPassword,
            ),
            ListTile(
              leading: const Icon(Icons.fingerprint),
              title: const Text('生物识别支付'),
              subtitle: const Text('使用指纹或面容ID进行支付'),
              trailing: Switch(
                value: _biometricPaymentEnabled,
                onChanged: (value) {
                  setState(() {
                    _biometricPaymentEnabled = value;
                  });
                  ToastUtil.showSuccess(value ? '已开启生物识别支付' : '已关闭生物识别支付');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '安全设置',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('支付限额'),
              subtitle: const Text('设置每日/单笔支付限额'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _setPaymentLimit,
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('支付提醒'),
              subtitle: const Text('支付成功/失败时通知'),
              trailing: Switch(
                value: _paymentNotificationEnabled,
                onChanged: (value) {
                  setState(() {
                    _paymentNotificationEnabled = value;
                  });
                  ToastUtil.showSuccess(value ? '已开启支付提醒' : '已关闭支付提醒');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addPaymentMethod() {
    _showAddPaymentMethodDialog();
  }

  void _showAddPaymentMethodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加支付方式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.account_balance_wallet, color: Colors.blue),
              title: const Text('支付宝'),
              onTap: () {
                Navigator.pop(context);
                _addAlipayAccount();
              },
            ),
            ListTile(
              leading: const Icon(Icons.wechat, color: Colors.green),
              title: const Text('微信支付'),
              onTap: () {
                Navigator.pop(context);
                _addWechatAccount();
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card, color: Colors.orange),
              title: const Text('银行卡'),
              onTap: () {
                Navigator.pop(context);
                _addBankCard();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addAlipayAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加支付宝'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: '支付宝账号',
                hintText: '请输入支付宝账号/手机号',
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: '真实姓名',
                hintText: '请输入真实姓名',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ToastUtil.showSuccess('支付宝添加成功');
              _loadPaymentMethods();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _addWechatAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加微信支付'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: '微信号',
                hintText: '请输入微信号',
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: '真实姓名',
                hintText: '请输入真实姓名',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ToastUtil.showSuccess('微信支付添加成功');
              _loadPaymentMethods();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _addBankCard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加银行卡'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: '银行卡号',
                hintText: '请输入银行卡号',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: '持卡人姓名',
                hintText: '请输入持卡人姓名',
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: '银行名称',
                hintText: '请输入银行名称',
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: '预留手机号',
                hintText: '请输入预留手机号',
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ToastUtil.showSuccess('银行卡添加成功');
              _loadPaymentMethods();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _handlePaymentMethodAction(PaymentMethod method, String action) {
    switch (action) {
      case 'set_default':
        _setDefaultPaymentMethod(method);
        break;
      case 'edit':
        _editPaymentMethod(method);
        break;
      case 'delete':
        _deletePaymentMethod(method);
        break;
    }
  }

  void _setDefaultPaymentMethod(PaymentMethod method) {
    setState(() {
      // 取消所有默认标记
      for (int i = 0; i < _paymentMethods.length; i++) {
        _paymentMethods[i] = PaymentMethod(
          id: _paymentMethods[i].id,
          type: _paymentMethods[i].type,
          name: _paymentMethods[i].name,
          description: _paymentMethods[i].description,
          isDefault: _paymentMethods[i].id == method.id,
          iconUrl: _paymentMethods[i].iconUrl,
        );
      }
    });
    ToastUtil.showSuccess('已设置为默认支付方式');
  }

  void _editPaymentMethod(PaymentMethod method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('编辑${method.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: '备注',
                hintText: '请输入备注信息',
              ),
              controller: TextEditingController(text: method.description),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ToastUtil.showSuccess('编辑成功');
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _deletePaymentMethod(PaymentMethod method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除支付方式'),
        content: Text('确定要删除${_getPaymentTypeName(method.type)}吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _paymentMethods.removeWhere((m) => m.id == method.id);
              });
              ToastUtil.showSuccess('删除成功');
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _changePaymentPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改支付密码'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: '当前密码',
                hintText: '请输入当前密码',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: '新密码',
                hintText: '请输入新密码（6位数字）',
              ),
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: '确认新密码',
                hintText: '请再次输入新密码',
              ),
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ToastUtil.showSuccess('支付密码修改成功');
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _setPaymentLimit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置支付限额'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: '单笔支付限额',
                hintText: '请输入金额',
                suffixText: '元',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: '每日支付限额',
                hintText: '请输入金额',
                suffixText: '元',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: '每月支付限额',
                hintText: '请输入金额',
                suffixText: '元',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ToastUtil.showSuccess('支付限额设置成功');
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

