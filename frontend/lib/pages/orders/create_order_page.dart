import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_text_field.dart';

class CreateOrderPage extends StatefulWidget {
  final Map<String, dynamic> player;

  const CreateOrderPage({super.key, required this.player});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _requirementsController = TextEditingController();
  final _contactInfoController = TextEditingController();
  
  ServiceType _selectedServiceType = ServiceType.gameGuide;
  int _selectedDuration = 60; // 默认1小时
  bool _isLoading = false;

  final List<int> _durationOptions = [30, 60, 90, 120, 180]; // 分钟

  @override
  void initState() {
    super.initState();
    _contactInfoController.text = '游戏ID/联系方式';
  }

  @override
  void dispose() {
    _requirementsController.dispose();
    _contactInfoController.dispose();
    super.dispose();
  }

  Future<void> _createOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      
      final orderData = {
        'playerId': widget.player['id'],
        'serviceType': _selectedServiceType.name,
        'duration': _selectedDuration,
        'requirements': _requirementsController.text,
        'contactInfo': _contactInfoController.text,
      };

      final response = await ApiService.createOrder(orderData);
      
      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('订单创建成功！')),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        throw Exception(response['message'] ?? '创建订单失败');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建订单失败: $e')),
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

  double _calculateTotalAmount() {
    final priceText = widget.player['price'] ?? '0元/小时';
    final price = double.tryParse(priceText.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    return price * (_selectedDuration / 60);
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.player;
    final totalAmount = _calculateTotalAmount();

    return Scaffold(
      appBar: AppBar(
        title: const Text('创建订单'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 陪玩信息卡片
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(player['avatar'] ?? ''),
                        child: player['avatar'] == null 
                            ? const Icon(Icons.person, size: 30)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player['name'] ?? '未知用户',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              player['game'] ?? '游戏达人',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              player['price'] ?? '0元/小时',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 服务类型选择
              Text(
                '服务类型',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ServiceType.values.map((type) {
                  final isSelected = _selectedServiceType == type;
                  return FilterChip(
                    label: Text(_getServiceTypeText(type)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedServiceType = type;
                      });
                    },
                    backgroundColor: isSelected 
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                        : null,
                    selectedColor: Theme.of(context).colorScheme.primary,
                    checkmarkColor: Colors.white,
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // 时长选择
              Text(
                '服务时长',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _durationOptions.map((duration) {
                  final isSelected = _selectedDuration == duration;
                  final hours = duration / 60;
                  return FilterChip(
                    label: Text('${hours.toInt()}小时'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedDuration = duration;
                      });
                    },
                    backgroundColor: isSelected 
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                        : null,
                    selectedColor: Theme.of(context).colorScheme.primary,
                    checkmarkColor: Colors.white,
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // 需求描述
              CustomTextField(
                controller: _requirementsController,
                labelText: '需求描述（选填）',
                hintText: '请描述您的具体需求，如游戏段位、玩法要求等',
                maxLines: 3,
                validator: (value) {
                  if (value != null && value.length > 500) {
                    return '需求描述不能超过500字';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // 联系方式
              CustomTextField(
                controller: _contactInfoController,
                labelText: '联系方式',
                hintText: '请输入您的游戏ID或联系方式',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入联系方式';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              
              // 费用总计
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '总计',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '¥${totalAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 提交按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createOrder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          '确认下单',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getServiceTypeText(ServiceType type) {
    switch (type) {
      case ServiceType.voice:
        return '语音陪玩';
      case ServiceType.video:
        return '视频陪玩';
      case ServiceType.gameGuide:
        return '游戏指导';
      case ServiceType.entertainment:
        return '娱乐陪玩';
    }
  }
}