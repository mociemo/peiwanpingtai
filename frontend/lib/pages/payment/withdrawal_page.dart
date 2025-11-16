import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/withdrawal_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/custom_button.dart';
import '../../utils/toast_util.dart';

/// 提现页面
class WithdrawalPage extends StatefulWidget {
  const WithdrawalPage({super.key});

  @override
  State<WithdrawalPage> createState() => _WithdrawalPageState();
}

class _WithdrawalPageState extends State<WithdrawalPage> {
  final List<double> _amountOptions = [10, 20, 50, 100, 200, 500];
  double _selectedAmount = 50;
  String _selectedAccountType = 'bank'; // bank, alipay, wechat
  Map<String, dynamic>? _selectedAccount;
  final TextEditingController _customAmountController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _accountInfoController = TextEditingController();
  bool _showAddAccountForm = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    _accountNameController.dispose();
    _accountInfoController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final withdrawalProvider = Provider.of<WithdrawalProvider>(
      context,
      listen: false,
    );
    await Future.wait([
      withdrawalProvider.getAvailableBalance(),
      withdrawalProvider.getWithdrawalRules(),
      withdrawalProvider.getUserWithdrawalAccounts(),
    ]);
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

  Future<void> _createWithdrawalApplication() async {
    final withdrawalProvider = Provider.of<WithdrawalProvider>(
      context,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.currentUser == null) {
      ToastUtil.showError('请先登录');
      return;
    }

    // 检查余额是否足够
    if (_selectedAmount > withdrawalProvider.availableBalance) {
      ToastUtil.showError('余额不足');
      return;
    }

    // 检查是否选择了账户
    if (_selectedAccount == null && !_showAddAccountForm) {
      ToastUtil.showError('请选择提现账户');
      return;
    }

    // 如果是添加新账户，检查表单
    if (_showAddAccountForm) {
      if (_accountNameController.text.isEmpty ||
          _accountInfoController.text.isEmpty) {
        ToastUtil.showError('请填写完整的账户信息');
        return;
      }
    }

    final success = await withdrawalProvider.createWithdrawalApplication(
      amount: _selectedAmount,
      accountType: _selectedAccountType,
      accountInfo: _showAddAccountForm
          ? _accountInfoController.text
          : _selectedAccount!['accountInfo'],
      accountName: _showAddAccountForm
          ? _accountNameController.text
          : _selectedAccount!['accountName'],
    );

    if (success) {
      ToastUtil.showSuccess('提现申请已提交');
      _resetForm();
      // 跳转到提现记录页面
      if (mounted) {
        Navigator.of(context).pushNamed('/withdrawal/records');
      }
    } else if (withdrawalProvider.errorMessage != null) {
      ToastUtil.showError(withdrawalProvider.errorMessage!);
    }
  }

  void _resetForm() {
    setState(() {
      _selectedAmount = 50;
      _customAmountController.text = '50';
      _selectedAccount = null;
      _showAddAccountForm = false;
      _accountNameController.clear();
      _accountInfoController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('提现'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).pushNamed('/withdrawal/records');
            },
            tooltip: '提现记录',
          ),
        ],
      ),
      body: Consumer<WithdrawalProvider>(
        builder: (context, withdrawalProvider, child) {
          if (withdrawalProvider.isLoading &&
              withdrawalProvider.availableBalance == 0) {
            return const LoadingWidget();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 可提现余额显示
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
                        '可提现余额',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '¥${withdrawalProvider.availableBalance.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (withdrawalProvider.withdrawalRules.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          '提现规则: ${withdrawalProvider.withdrawalRules['description'] ?? '最低提现金额¥${withdrawalProvider.withdrawalRules['minAmount'] ?? '10.00'}'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 提现金额选择
                Text('选择提现金额', style: Theme.of(context).textTheme.titleMedium),
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
                    final isAvailable =
                        amount <= withdrawalProvider.availableBalance;

                    return GestureDetector(
                      onTap: isAvailable ? () => _selectAmount(amount) : null,
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
                                  : isAvailable
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Colors.grey,
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
                  decoration: InputDecoration(
                    labelText: '自定义金额',
                    prefixText: '¥',
                    border: const OutlineInputBorder(),
                    suffixText: '全部提现',
                    suffixStyle: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  onChanged: _onCustomAmountChanged,
                  onTap: () {
                    // 点击"全部提现"文本
                    if (_customAmountController.selection.baseOffset ==
                        _customAmountController.text.length) {
                      _selectAmount(withdrawalProvider.availableBalance);
                    }
                  },
                ),

                const SizedBox(height: 24),

                // 提现账户选择
                Text('选择提现账户', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),

                // 账户类型选择
                Row(
                  children: [
                    _buildAccountTypeOption('bank', '银行卡'),
                    const SizedBox(width: 12),
                    _buildAccountTypeOption('alipay', '支付宝'),
                    const SizedBox(width: 12),
                    _buildAccountTypeOption('wechat', '微信'),
                  ],
                ),

                const SizedBox(height: 16),

                // 账户选择或添加
                if (!_showAddAccountForm &&
                    withdrawalProvider.userAccounts.isNotEmpty) ...[
                  // 已有账户列表
                  ...withdrawalProvider.userAccounts
                      .where(
                        (account) =>
                            account['accountType'] == _selectedAccountType,
                      )
                      .map((account) => _buildAccountOption(account)),

                  // 添加新账户按钮
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '添加新账户',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (_showAddAccountForm) ...[
                  // 添加新账户表单
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _accountNameController,
                          decoration: InputDecoration(
                            labelText: _getAccountNameLabel(),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _accountInfoController,
                          decoration: InputDecoration(
                            labelText: _getAccountInfoLabel(),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _showAddAccountForm = false;
                                });
                              },
                              child: const Text('取消'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ] else if (withdrawalProvider.userAccounts.isEmpty) ...[
                  // 没有账户，显示添加账户按钮
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showAddAccountForm = true;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '添加${_getAccountTypeName()}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // 提现按钮
                CustomButton(
                  text: '提现 ¥${_selectedAmount.toStringAsFixed(2)}',
                  onPressed: _createWithdrawalApplication,
                  isLoading: withdrawalProvider.isLoading,
                ),

                const SizedBox(height: 16),

                // 提现说明
                Text(
                  '提现说明：\n1. 提现将在1-3个工作日内到账\n2. 提现手续费按平台规定收取\n3. 如有疑问请联系客服',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccountTypeOption(String type, String title) {
    final isSelected = _selectedAccountType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAccountType = type;
          _selectedAccount = null;
          _showAddAccountForm = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildAccountOption(Map<String, dynamic> account) {
    final isSelected = _selectedAccount?['id'] == account['id'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAccount = account;
          _showAddAccountForm = false;
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
            // 账户类型图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_getAccountIcon(), size: 24),
            ),

            const SizedBox(width: 16),

            // 账户信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account['accountName'] ?? '',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _maskAccountInfo(account['accountInfo'] ?? ''),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
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

  String _getAccountTypeName() {
    switch (_selectedAccountType) {
      case 'bank':
        return '银行卡';
      case 'alipay':
        return '支付宝';
      case 'wechat':
        return '微信';
      default:
        return '账户';
    }
  }

  String _getAccountNameLabel() {
    switch (_selectedAccountType) {
      case 'bank':
        return '开户名';
      case 'alipay':
        return '支付宝姓名';
      case 'wechat':
        return '微信姓名';
      default:
        return '账户名';
    }
  }

  String _getAccountInfoLabel() {
    switch (_selectedAccountType) {
      case 'bank':
        return '银行卡号';
      case 'alipay':
        return '支付宝账号';
      case 'wechat':
        return '微信号';
      default:
        return '账户信息';
    }
  }

  IconData _getAccountIcon() {
    switch (_selectedAccountType) {
      case 'bank':
        return Icons.credit_card;
      case 'alipay':
        return Icons.account_balance_wallet;
      case 'wechat':
        return Icons.chat;
      default:
        return Icons.payment;
    }
  }

  String _maskAccountInfo(String accountInfo) {
    if (accountInfo.length <= 4) return accountInfo;

    switch (_selectedAccountType) {
      case 'bank':
        // 银行卡号显示前4位和后4位，中间用*代替
        return '${accountInfo.substring(0, 4)} **** **** ${accountInfo.substring(accountInfo.length - 4)}';
      case 'alipay':
      case 'wechat':
        // 支付宝和微信显示前2位和后2位，中间用*代替
        if (accountInfo.length <= 4) return accountInfo;
        return '${accountInfo.substring(0, 2)} **** ${accountInfo.substring(accountInfo.length - 2)}';
      default:
        return accountInfo;
    }
  }
}
