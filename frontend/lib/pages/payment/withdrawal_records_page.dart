import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/withdrawal_application_model.dart';
import '../../providers/withdrawal_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_widget.dart';
import '../../utils/toast_util.dart';

/// 提现记录页面
class WithdrawalRecordsPage extends StatefulWidget {
  const WithdrawalRecordsPage({super.key});

  @override
  State<WithdrawalRecordsPage> createState() => _WithdrawalRecordsPageState();
}

class _WithdrawalRecordsPageState extends State<WithdrawalRecordsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final List<String> _tabTitles = ['全部', '待审核', '已通过', '已拒绝', '已完成'];
  final List<String?> _tabStatuses = [
    null,
    'pending',
    'approved',
    'rejected',
    'completed',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _scrollController.addListener(_onScroll);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    _loadWithdrawalApplications(refresh: true);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadWithdrawalApplications();
    }
  }

  Future<void> _loadData() async {
    await _loadWithdrawalApplications(refresh: true);
  }

  Future<void> _loadWithdrawalApplications({bool refresh = false}) async {
    final withdrawalProvider = Provider.of<WithdrawalProvider>(
      context,
      listen: false,
    );

    await withdrawalProvider.getWithdrawalApplications(
      refresh: refresh,
      status: _tabStatuses[_tabController.index],
    );
  }

  Future<void> _cancelWithdrawal(String applicationId) async {
    final withdrawalProvider = Provider.of<WithdrawalProvider>(
      context,
      listen: false,
    );

    final success = await withdrawalProvider.cancelWithdrawalApplication(
      applicationId,
    );

    if (success) {
      ToastUtil.showSuccess('提现申请已取消');
    } else if (withdrawalProvider.errorMessage != null) {
      ToastUtil.showError(withdrawalProvider.errorMessage!);
    }
  }

  void _showWithdrawalDetail(WithdrawalApplication application) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('提现详情', style: Theme.of(context).textTheme.titleLarge),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    application.status,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(application.status),
                      color: _getStatusColor(application.status),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getStatusText(application.status),
                      style: TextStyle(
                        color: _getStatusColor(application.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _buildDetailItem(
                '提现金额',
                '¥${application.amount.toStringAsFixed(2)}',
              ),
              _buildDetailItem(
                '手续费',
                '¥${(application.fee ?? 0).toStringAsFixed(2)}',
              ),
              _buildDetailItem(
                '实际到账',
                '¥${application.actualAmount.toStringAsFixed(2)}',
              ),
              _buildDetailItem(
                '账户类型',
                _getAccountTypeText(application.accountType),
              ),
              _buildDetailItem('账户姓名', application.accountName),
              _buildDetailItem(
                '账户信息',
                _maskAccountInfo(
                  application.accountInfo,
                  application.accountType,
                ),
              ),

              const SizedBox(height: 16),

              _buildDetailItem(
                '申请时间',
                DateFormat(
                  'yyyy-MM-dd HH:mm:ss',
                ).format(application.createTime),
              ),
              if (application.processTime != null)
                _buildDetailItem(
                  '处理时间',
                  DateFormat(
                    'yyyy-MM-dd HH:mm:ss',
                  ).format(application.processTime!),
                ),

              if (application.remark != null &&
                  application.remark!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('备注', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
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
                  child: Text(application.remark!),
                ),
              ],

              const SizedBox(height: 24),

              if (application.isPending)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _cancelWithdrawal(application.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('取消提现'),
                  ),
                ),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return '待审核';
      case 'approved':
        return '已通过';
      case 'rejected':
        return '已拒绝';
      case 'completed':
        return '已完成';
      case 'cancelled':
        return '已取消';
      default:
        return '未知状态';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.not_interested;
      default:
        return Icons.help;
    }
  }

  String _getAccountTypeText(String accountType) {
    switch (accountType) {
      case 'bank':
        return '银行卡';
      case 'alipay':
        return '支付宝';
      case 'wechat':
        return '微信';
      default:
        return '未知';
    }
  }

  String _maskAccountInfo(String accountInfo, String accountType) {
    if (accountInfo.length <= 4) return accountInfo;

    switch (accountType) {
      case 'bank':
        return '${accountInfo.substring(0, 4)} **** **** ${accountInfo.substring(accountInfo.length - 4)}';
      case 'alipay':
      case 'wechat':
        if (accountInfo.length <= 4) return accountInfo;
        return '${accountInfo.substring(0, 2)} **** ${accountInfo.substring(accountInfo.length - 2)}';
      default:
        return accountInfo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('提现记录'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<WithdrawalProvider>(
        builder: (context, withdrawalProvider, child) {
          return Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
                isScrollable: true,
                indicatorColor: Theme.of(context).colorScheme.primary,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _tabTitles.map((title) {
                    return _buildWithdrawalList(withdrawalProvider);
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWithdrawalList(WithdrawalProvider withdrawalProvider) {
    if (withdrawalProvider.isLoading &&
        withdrawalProvider.withdrawalApplications.isEmpty) {
      return const LoadingWidget();
    }

    if (withdrawalProvider.withdrawalApplications.isEmpty &&
        !withdrawalProvider.isLoading) {
      return const EmptyWidget(
        message: '暂无提现记录',
        icon: Icons.account_balance_wallet,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _loadWithdrawalApplications(refresh: true);
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount:
            withdrawalProvider.withdrawalApplications.length +
            (withdrawalProvider.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == withdrawalProvider.withdrawalApplications.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final application = withdrawalProvider.withdrawalApplications[index];
          return _buildWithdrawalItem(application);
        },
      ),
    );
  }

  Widget _buildWithdrawalItem(WithdrawalApplication application) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getAccountTypeColor(
                              application.accountType,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getAccountTypeText(application.accountType),
                            style: TextStyle(
                              color: _getAccountTypeColor(
                                application.accountType,
                              ),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              application.status,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getStatusText(application.status),
                            style: TextStyle(
                              color: _getStatusColor(application.status),
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      application.accountName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _maskAccountInfo(
                        application.accountInfo,
                        application.accountType,
                      ),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '¥${application.amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (application.fee != null && application.fee! > 0)
                    Text(
                      '手续费: ¥${application.fee!.toStringAsFixed(2)}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('yyyy-MM-dd HH:mm').format(application.createTime),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => _showWithdrawalDetail(application),
                child: const Text('详情'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getAccountTypeColor(String accountType) {
    switch (accountType) {
      case 'bank':
        return Colors.blue;
      case 'alipay':
        return Colors.blue;
      case 'wechat':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
