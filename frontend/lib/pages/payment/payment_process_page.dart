import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/payment_provider.dart';
import '../../widgets/common/loading_widget.dart';

/// 支付处理页面
class PaymentProcessPage extends StatefulWidget {
  const PaymentProcessPage({super.key});

  @override
  State<PaymentProcessPage> createState() => _PaymentProcessPageState();
}

class _PaymentProcessPageState extends State<PaymentProcessPage> {
  String? _orderId;
  double? _amount;
  String? _paymentMethod;
  bool _isProcessing = false;
  bool _isCompleted = false;
  bool _isFailed = false;
  String? _errorMessage;
  Timer? _statusCheckTimer;

  @override
  void initState() {
    super.initState();
    _getArguments();
    _startPayment();
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  void _getArguments() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _orderId = args['orderId'] as String?;
      _amount = args['amount'] as double?;
      _paymentMethod = args['paymentMethod'] as String?;
    }
  }

  void _startPayment() async {
    if (_orderId == null || _paymentMethod == null) {
      setState(() {
        _isFailed = true;
        _errorMessage = '支付参数错误';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
      
      // 获取支付参数
      final paymentParams = await paymentProvider.getPaymentParams(_orderId!);
      
      if (paymentParams != null) {
        // 根据支付方式调用相应的支付SDK
        await _callPaymentSDK(_paymentMethod!, paymentParams);
        
        // 启动状态检查定时器
        _startStatusCheck();
      } else {
        setState(() {
          _isFailed = true;
          _errorMessage = paymentProvider.errorMessage ?? '获取支付参数失败';
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _isFailed = true;
        _errorMessage = e.toString();
        _isProcessing = false;
      });
    }
  }

  Future<void> _callPaymentSDK(String paymentMethod, Map<String, dynamic> params) async {
    // 这里应该调用相应的支付SDK
    // 由于是示例，我们只是模拟支付过程
    
    switch (paymentMethod) {
      case 'wechat':
        // 调用微信支付SDK
        await _simulateWechatPay(params);
        break;
      case 'alipay':
        // 调用支付宝SDK
        await _simulateAlipay(params);
        break;
      case 'bank':
        // 调用银行卡支付SDK
        await _simulateBankPay(params);
        break;
      default:
        throw Exception('不支持的支付方式');
    }
  }

  Future<void> _simulateWechatPay(Map<String, dynamic> params) async {
    // 模拟微信支付
    await Future.delayed(const Duration(seconds: 2));
    
    // 这里应该调用微信支付SDK
    // 例如：fluwx或flutter_wechat_kit
    
    // 模拟支付结果
    // 在实际应用中，支付结果会通过SDK回调返回
    // 这里我们模拟支付成功
  }

  Future<void> _simulateAlipay(Map<String, dynamic> params) async {
    // 模拟支付宝支付
    await Future.delayed(const Duration(seconds: 2));
    
    // 这里应该调用支付宝SDK
    // 例如：flutter_alipay
    
    // 模拟支付结果
    // 在实际应用中，支付结果会通过SDK回调返回
    // 这里我们模拟支付成功
  }

  Future<void> _simulateBankPay(Map<String, dynamic> params) async {
    // 模拟银行卡支付
    await Future.delayed(const Duration(seconds: 2));
    
    // 这里应该调用银行卡支付SDK或跳转到银行支付页面
    
    // 模拟支付结果
    // 在实际应用中，支付结果会通过SDK回调返回
    // 这里我们模拟支付成功
  }

  void _startStatusCheck() {
    // 启动定时器，定期检查支付状态
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkPaymentStatus();
    });
  }

  Future<void> _checkPaymentStatus() async {
    if (_orderId == null) return;
    
    try {
      final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
      final success = await paymentProvider.getRechargeOrderDetail(_orderId!);
      
      if (success && paymentProvider.currentOrder != null) {
        final order = paymentProvider.currentOrder!;
        
        if (order.isPaid) {
          // 支付成功
          _statusCheckTimer?.cancel();
          setState(() {
            _isProcessing = false;
            _isCompleted = true;
          });
        } else if (order.isFailed || order.isCancelled) {
          // 支付失败或取消
          _statusCheckTimer?.cancel();
          setState(() {
            _isProcessing = false;
            _isFailed = true;
            _errorMessage = '支付失败或已取消';
          });
        }
      }
    } catch (e) {
      // 检查状态失败，继续检查
    }
  }

  void _onBackPressed() {
    if (_isCompleted) {
      // 支付成功，返回到充值页面并刷新
      Navigator.of(context).popUntil((route) => route.settings.name == '/recharge');
    } else {
      // 支付失败或进行中，直接返回
      Navigator.of(context).pop();
    }
  }

  void _retryPayment() {
    setState(() {
      _isProcessing = false;
      _isFailed = false;
      _errorMessage = null;
    });
    
    // 重新开始支付
    _startPayment();
  }

  void _viewOrderDetail() {
    if (_orderId != null) {
      Navigator.of(context).pushNamed(
        '/payment/order/detail',
        arguments: {'orderId': _orderId},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _onBackPressed();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getPaymentTitle()),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _onBackPressed,
          ),
        ),
        body: _buildBody(),
      ),
    );
  }

  String _getPaymentTitle() {
    switch (_paymentMethod) {
      case 'wechat':
        return '微信支付';
      case 'alipay':
        return '支付宝支付';
      case 'bank':
        return '银行卡支付';
      default:
        return '支付';
    }
  }

  Widget _buildBody() {
    if (_isProcessing) {
      return _buildProcessingView();
    } else if (_isCompleted) {
      return _buildCompletedView();
    } else if (_isFailed) {
      return _buildFailedView();
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildProcessingView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 支付方式图标
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              _getPaymentIcon(),
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 支付金额
          Text(
            '¥${_amount?.toStringAsFixed(2) ?? '0.00'}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 支付状态
          Text(
            '正在支付...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          
          const SizedBox(height: 32),
          
          // 加载动画
          const LoadingWidget(),
          
          const SizedBox(height: 32),
          
          // 提示信息
          Text(
            '请在${_getPaymentTitle()}中完成支付',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '支付完成后将自动返回',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 成功图标
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.check_circle,
              size: 40,
              color: Colors.green,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 支付成功
          Text(
            '支付成功',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 支付金额
          Text(
            '¥${_amount?.toStringAsFixed(2) ?? '0.00'}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          
          const SizedBox(height: 8),
          
          // 支付方式
          Text(
            _getPaymentTitle(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 操作按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.settings.name == '/recharge'),
              child: const Text('返回充值'),
            ),
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _viewOrderDetail,
              child: const Text('查看订单'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailedView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 失败图标
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.error,
              size: 40,
              color: Colors.red,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 支付失败
          Text(
            '支付失败',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 错误信息
          if (_errorMessage != null)
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          
          const SizedBox(height: 32),
          
          // 操作按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _retryPayment,
              child: const Text('重新支付'),
            ),
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('返回'),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentIcon() {
    switch (_paymentMethod) {
      case 'wechat':
        return Icons.wechat;
      case 'alipay':
        return Icons.account_balance_wallet;
      case 'bank':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }
}