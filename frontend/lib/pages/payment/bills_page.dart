import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/bill_model.dart';
import '../../providers/bill_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_widget.dart';
import '../../utils/toast_util.dart';

/// 账单查询页面
class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final List<String> _tabTitles = ['全部', '充值', '消费', '收入', '提现'];
  final List<String?> _tabTypes = [
    null,
    'recharge',
    'consumption',
    'income',
    'withdrawal',
  ];

  DateTime? _startTime;
  DateTime? _endTime;

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

    final billProvider = Provider.of<BillProvider>(context, listen: false);
    billProvider.setFilters(type: _tabTypes[_tabController.index]);
    _loadBills(refresh: true);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadBills();
    }
  }

  Future<void> _loadData() async {
    final billProvider = Provider.of<BillProvider>(context, listen: false);

    await Future.wait([
      billProvider.getUserBalance(),
      billProvider.getBillStatistics(),
      _loadBills(refresh: true),
    ]);
  }

  Future<void> _loadBills({bool refresh = false}) async {
    final billProvider = Provider.of<BillProvider>(context, listen: false);

    await billProvider.getUserBills(
      refresh: refresh,
      type: _tabTypes[_tabController.index],
      startTime: _startTime,
      endTime: _endTime,
    );
  }

  void _showFilterBottomSheet() {
    final billProvider = Provider.of<BillProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
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
                  Text('筛选条件', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),

                  // 时间范围选择
                  Text('时间范围', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate:
                                  _startTime ??
                                  DateTime.now().subtract(
                                    const Duration(days: 30),
                                  ),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setModalState(() {
                                _startTime = date;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  _startTime != null
                                      ? DateFormat(
                                          'yyyy-MM-dd',
                                        ).format(_startTime!)
                                      : '开始日期',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _endTime ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setModalState(() {
                                _endTime = date;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  _endTime != null
                                      ? DateFormat(
                                          'yyyy-MM-dd',
                                        ).format(_endTime!)
                                      : '结束日期',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 快捷时间选择
                  Text('快捷选择', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickFilter('今天', () {
                        final now = DateTime.now();
                        setModalState(() {
                          _startTime = DateTime(now.year, now.month, now.day);
                          _endTime = DateTime(
                            now.year,
                            now.month,
                            now.day,
                            23,
                            59,
                            59,
                          );
                        });
                      }),
                      _buildQuickFilter('本周', () {
                        final now = DateTime.now();
                        final weekDay = now.weekday;
                        setModalState(() {
                          _startTime = now.subtract(
                            Duration(days: weekDay - 1),
                          );
                          _endTime = now;
                        });
                      }),
                      _buildQuickFilter('本月', () {
                        final now = DateTime.now();
                        setModalState(() {
                          _startTime = DateTime(now.year, now.month, 1);
                          _endTime = now;
                        });
                      }),
                      _buildQuickFilter('最近三个月', () {
                        final now = DateTime.now();
                        setModalState(() {
                          _startTime = DateTime(
                            now.year,
                            now.month - 3,
                            now.day,
                          );
                          _endTime = now;
                        });
                      }),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 操作按钮
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              _startTime = null;
                              _endTime = null;
                            });
                          },
                          child: const Text('重置'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              billProvider.setFilters(
                                type: _tabTypes[_tabController.index],
                                startTime: _startTime,
                                endTime: _endTime,
                              );
                            });
                            Navigator.of(context).pop();
                            _loadBills(refresh: true);
                          },
                          child: const Text('确定'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickFilter(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Future<void> _exportBills() async {
    final billProvider = Provider.of<BillProvider>(context, listen: false);

    final downloadUrl = await billProvider.exportBills();

    if (downloadUrl != null) {
      ToastUtil.showSuccess('账单导出成功');
      // 这里可以添加下载逻辑或打开浏览器
    } else if (billProvider.errorMessage != null) {
      ToastUtil.showError(billProvider.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('账单查询'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
            tooltip: '筛选',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportBills,
            tooltip: '导出',
          ),
        ],
      ),
      body: Consumer<BillProvider>(
        builder: (context, billProvider, child) {
          return Column(
            children: [
              // 余额和统计信息
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  children: [
                    // 余额显示
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '账户余额',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '¥${billProvider.userBalance.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 筛选条件显示
                    if (_startTime != null || _endTime != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.filter_list,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${_startTime != null ? DateFormat('yyyy-MM-dd').format(_startTime!) : '开始'} 至 ${_endTime != null ? DateFormat('yyyy-MM-dd').format(_endTime!) : '结束'}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.clear, size: 16),
                              onPressed: () {
                                setState(() {
                                  _startTime = null;
                                  _endTime = null;
                                  billProvider.clearFilters();
                                });
                                _loadBills(refresh: true);
                              },
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Tab栏
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

              // 账单列表
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _tabTitles.map((title) {
                    return _buildBillsList(billProvider);
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBillsList(BillProvider billProvider) {
    if (billProvider.isLoading && billProvider.bills.isEmpty) {
      return const LoadingWidget();
    }

    if (billProvider.bills.isEmpty && !billProvider.isLoading) {
      return const EmptyWidget(message: '暂无账单记录', icon: Icons.receipt_long);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _loadBills(refresh: true);
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: billProvider.bills.length + (billProvider.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == billProvider.bills.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final bill = billProvider.bills[index];
          return _buildBillItem(bill);
        },
      ),
    );
  }

  Widget _buildBillItem(Bill bill) {
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
              // 账单类型和描述
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
                            color: _getBillTypeColor(
                              bill.type,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            bill.typeName,
                            style: TextStyle(
                              color: _getBillTypeColor(bill.type),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (bill.isIncome)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '收入',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bill.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // 金额
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    bill.formattedAmount,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: bill.isIncome ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '余额: ${bill.formattedBalance}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 时间
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('yyyy-MM-dd HH:mm:ss').format(bill.createTime),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              if (bill.relatedOrderId != null)
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    // 跳转到相关订单详情
                    Navigator.of(context).pushNamed(
                      '/order/detail',
                      arguments: {'orderId': bill.relatedOrderId},
                    );
                  },
                  child: const Text('查看订单'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getBillTypeColor(String type) {
    switch (type) {
      case 'recharge':
        return Colors.blue;
      case 'consumption':
        return Colors.orange;
      case 'income':
        return Colors.green;
      case 'withdrawal':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
