import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/recharge_order_model.dart';
import '../../providers/payment_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/custom_button.dart';
import '../../utils/toast_util.dart';

/// 充值页面
class RechargePage extends StatefulWidget {
  const RechargePage({super.key});

  @override
  State<RechargePage> createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage> {
  final List<double> _amountOptions = [10, 20, 50, 100, 200, 500];
  double _selectedAmount = 50;
  String _selectedPaymentMethod = 'wechat'; // wechat, alipay, bank
  Map<String, dynamic>? _selectedDiscount;
  final TextEditingController _customAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );
    await Future.wait([paymentProvider.getRechargeDiscounts()]);
  }

  void _selectAmount(double amount) {
    setState(() {
      _selectedAmount = amount;
      _customAmountController.text = amount.toString();
    });
  }

  void _onCustomAmountChanged(String value) {
    if (value.isNotEmpty) {
      final amount = double.tryParse(value);
      if (amount != null && amount > 0) {
        setState(() {
          _selectedAmount = amount;
        });
      }
    }
  }

  Future<void> _createRechargeOrder() async {
    final paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.currentUser == null) {
      ToastUtil.showError('请先登录');
      return;
    }

    final success = await paymentProvider.createRechargeOrder(
      amount: _selectedAmount,
      paymentMethod: _selectedPaymentMethod,
      discountId: _selectedDiscount?['id'],
    );

    if (success && paymentProvider.currentOrder != null) {
      // 跳转到支付页面
      _navigateToPayment(paymentProvider.currentOrder!);
    } else if (paymentProvider.errorMessage != null) {
      ToastUtil.showError(paymentProvider.errorMessage!);
    }
  }

  void _navigateToPayment(RechargeOrder order) {
    Navigator.of(context).pushNamed(
      '/payment/process',
      arguments: {
        'orderId': order.id,
        'amount': order.actualAmount,
        'paymentMethod': _selectedPaymentMethod,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('充值'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, child) {
          if (paymentProvider.isLoading && paymentProvider.discounts.isEmpty) {
            return const LoadingWidget();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 余额显示
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '当前余额',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          return Text(
                            '¥${(userProvider.currentUser?['balance'] ?? 0.0).toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 充值金额选择
                Text('选择充值金额', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),

                // 预设金额选项
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _amountOptions.length,
                  itemBuilder: (context, index) {
                    final amount = _amountOptions[index];
                    final isSelected = _selectedAmount == amount;

                    return GestureDetector(
                      onTap: () => _selectAmount(amount),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '¥$amount',
                            style: TextStyle(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // 自定义金额输入
                TextField(
                  controller: _customAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '自定义金额',
                    prefixText: '¥',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _onCustomAmountChanged,
                ),

                const SizedBox(height: 24),

                // 优惠券选择
                if (paymentProvider.discounts.isNotEmpty) ...[
                  Text('选择优惠券', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDiscount != null
                              ? '${_selectedDiscount!['name']} -¥${_selectedDiscount!['amount']}'
                              : '不使用优惠券',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () =>
                              _showDiscountSelector(paymentProvider),
                          child: const Text('选择'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],

                // 支付方式选择
                Text('选择支付方式', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),

                // 支付方式选项
                _buildPaymentOption(
                  'wechat',
                  '微信支付',
                  'assets/icons/wechat_pay.png',
                ),
                _buildPaymentOption('alipay', '支付宝', 'assets/icons/alipay.png'),
                _buildPaymentOption('bank', '银行卡', 'assets/icons/bank.png'),

                const SizedBox(height: 32),

                // 充值按钮
                CustomButton(
                  text: '充值 ¥${_selectedAmount.toStringAsFixed(2)}',
                  onPressed: _createRechargeOrder,
                  isLoading: paymentProvider.isLoading,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentOption(String method, String title, String iconPath) {
    final isSelected = _selectedPaymentMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Row(
          children: [
            // 支付方式图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.payment, size: 24),
            ),

            const SizedBox(width: 16),

            // 支付方式名称
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
            ),

            // 选择状态
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  void _showDiscountSelector(PaymentProvider paymentProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('选择优惠券', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),

              // 不使用优惠券选项
              ListTile(
                title: const Text('不使用优惠券'),
                trailing: _selectedDiscount == null
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  setState(() {
                    _selectedDiscount = null;
                  });
                  Navigator.of(context).pop();
                },
              ),

              // 优惠券列表
              ...paymentProvider.discounts.map((discount) {
                final isAvailable =
                    _selectedAmount >= (discount['minAmount'] ?? 0);

                return ListTile(
                  title: Text(discount['name'] ?? ''),
                  subtitle: Text('满${discount['minAmount']}可用'),
                  trailing: isAvailable
                      ? (_selectedDiscount?['id'] == discount['id']
                            ? Icon(
                                Icons.check,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null)
                      : Text('不可用', style: TextStyle(color: Colors.grey[500])),
                  onTap: isAvailable
                      ? () {
                          setState(() {
                            _selectedDiscount = discount;
                          });
                          Navigator.of(context).pop();
                        }
                      : null,
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
