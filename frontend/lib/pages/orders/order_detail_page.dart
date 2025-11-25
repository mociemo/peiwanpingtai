import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../services/api_service.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  Order? _order;
  bool _isLoading = true;
  bool _isActionLoading = false;
  int _rating = 0;


  @override
  void initState() {
    super.initState();
    _loadOrderDetail();
  }

  Future<void> _loadOrderDetail() async {
    try {
      final response = await ApiService.getOrderById(widget.orderId);
      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _order = Order.fromJson(response['data']);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取订单详情失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cancelOrder() async {
    setState(() {
      _isActionLoading = true;
    });

    try {
      final response = await ApiService.cancelOrder(widget.orderId, '用户取消');
      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('订单已取消')),
          );
          await _loadOrderDetail(); // 重新加载订单详情
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('取消订单失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isActionLoading = false;
        });
      }
    }
  }

  Future<void> _rateOrder() async {
    // 显示评价对话框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('评价服务'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('请为本次服务评分：'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () async {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    setState(() {
                      _rating = index + 1;
                    });
                    
                    try {
                      final response = await ApiService.rateOrder(
                        widget.orderId,
                        (index + 1).toString(),
                        '',
                      );
                      
                      if (!mounted) return;
                      
                      if (response['success'] == true) {
                        if (mounted) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(content: Text('评分成功')),
                          );
                        }
                        _loadOrderDetail(); // 重新加载订单详情
                      } else {
                        if (mounted) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(content: Text(response['message'] ?? '评分失败')),
                          );
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(content: Text('评分失败: $e')),
                        );
                      }
                    }
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: '评价内容',
                hintText: '请输入您的评价...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('评价提交成功')),
                );
              }
            },
            child: const Text('提交'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_order == null) return const SizedBox.shrink();

    switch (_order!.status) {
      case OrderStatus.pending:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isActionLoading ? null : _cancelOrder,
                child: _isActionLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('取消订单'),
              ),
            ),
          ],
        );
      
      case OrderStatus.accepted:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // 跳转到聊天页面
                  Navigator.pushNamed(context, '/chat', arguments: {
                    'userId': _order!.playerId,
                    'userName': _order!.playerName,
                  });
                },
                child: const Text('联系陪玩'),
              ),
            ),
          ],
        );
      
      case OrderStatus.inProgress:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // 跳转到服务页面或开始服务计时
                  Navigator.pushNamed(context, '/service', arguments: {
                    'orderId': _order!.id,
                    'playerId': _order!.playerId,
                  });
                },
                child: const Text('进入服务'),
              ),
            ),
          ],
        );
      
      case OrderStatus.completed:
        if (_order!.rating == null) {
          return Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // 再次下单
                    Navigator.pushNamed(context, '/player/detail', arguments: {
                      'playerId': _order!.playerId,
                    });
                  },
                  child: const Text('再次下单'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _rateOrder,
                  child: const Text('评价订单'),
                ),
              ),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // 再次下单
                    Navigator.pushNamed(context, '/player/detail', arguments: {
                      'playerId': _order!.playerId,
                    });
                  },
                  child: const Text('再次下单'),
                ),
              ),
            ],
          );
        }
      
      case OrderStatus.cancelled:
      case OrderStatus.refunded:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // 重新下单
                  Navigator.pushNamed(context, '/player/detail', arguments: {
                    'playerId': _order!.playerId,
                  });
                },
                child: const Text('重新下单'),
              ),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('订单详情'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
              ? const Center(child: Text('订单不存在'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 订单状态卡片
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '订单状态',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      _order!.statusText,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: _getStatusColor(_order!.status),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '订单编号',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    _order!.orderNo,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 陪玩信息
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundImage: NetworkImage(_order!.playerAvatar),
                                child: _order!.playerAvatar.isEmpty 
                                    ? const Icon(Icons.person, size: 25)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _order!.playerName,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _order!.serviceTypeText,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 订单详情
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '订单信息',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow('服务类型', _order!.serviceTypeText),
                              _buildInfoRow('服务时长', '${_order!.duration}分钟'),
                              _buildInfoRow('单价', '¥${_order!.amount.toStringAsFixed(2)}/小时'),
                              _buildInfoRow('总费用', '¥${_order!.totalAmount.toStringAsFixed(2)}'),
                              _buildInfoRow('创建时间', _formatDateTime(_order!.createTime)),
                              if (_order!.startTime != null)
                                _buildInfoRow('开始时间', _formatDateTime(_order!.startTime!)),
                              if (_order!.endTime != null)
                                _buildInfoRow('结束时间', _formatDateTime(_order!.endTime!)),
                            ],
                          ),
                        ),
                      ),
                      
                      if (_order!.requirements.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '需求描述',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(_order!.requirements),
                              ],
                            ),
                          ),
                        ),
                      ],
                      
                      if (_order!.contactInfo.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '联系方式',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(_order!.contactInfo),
                              ],
                            ),
                          ),
                        ),
                      ],
                      
                      if (_order!.cancelReason != null) ...[
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '取消原因',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(_order!.cancelReason!),
                              ],
                            ),
                          ),
                        ),
                      ],
                      
                      if (_order!.rating != null) ...[
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '评价信息',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text('评分: '),
                                    ...List.generate(5, (index) {
                                      return Icon(
                                        Icons.star,
                                        size: 16,
                                        color: index < _order!.rating! ? Colors.amber : Colors.grey.shade300,
                                      );
                                    }),
                                    Text(' ${_order!.rating!.toStringAsFixed(1)}'),
                                  ],
                                ),
                                if (_order!.comment != null) ...[
                                  const SizedBox(height: 8),
                                  Text('评价内容: ${_order!.comment}'),
                                ],
                                if (_order!.commentTime != null) ...[
                                  const SizedBox(height: 8),
                                  Text('评价时间: ${_formatDateTime(_order!.commentTime!)}'),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.accepted:
        return Colors.blue;
      case OrderStatus.inProgress:
        return Colors.green;
      case OrderStatus.completed:
        return Colors.grey;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.refunded:
        return Colors.purple;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}