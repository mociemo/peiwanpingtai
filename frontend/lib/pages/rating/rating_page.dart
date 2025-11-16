import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../services/rating_service.dart';
import '../../models/order_model.dart';
import '../../models/rating_model.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RatingPage extends StatefulWidget {
  final String orderId;

  const RatingPage({super.key, required this.orderId});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  final RatingService _ratingService = RatingService();
  final TextEditingController _commentController = TextEditingController();

  Order? _order;
  int _rating = 5;
  final List<String> _selectedTags = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  final List<String> _availableTags = [
    '技术好',
    '态度好',
    '沟通顺畅',
    '准时守约',
    '服务周到',
    '专业性强',
    '体验愉快',
    '值得推荐',
  ];

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadOrderDetails() async {
    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final order = await orderProvider.getOrderById(widget.orderId);
      setState(() {
        _order = order;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('加载订单详情失败: ${e.toString()}')));
      }
    }
  }

  Future<void> _submitRating() async {
    if (_order == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final ratingRequest = RatingRequest(
        orderId: widget.orderId,
        rating: _rating,
        comment: _commentController.text.trim(),
        tags: _selectedTags,
      );

      await _ratingService.createRating(authProvider.token!, ratingRequest);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('评价提交成功')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('提交评价失败: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('评价订单')),
      body: _isLoading
          ? const LoadingWidget()
          : _order == null
          ? const Center(child: Text('订单不存在'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderInfo(),
                  const SizedBox(height: 24),
                  _buildRatingSection(),
                  const SizedBox(height: 24),
                  _buildTagsSection(),
                  const SizedBox(height: 24),
                  _buildCommentSection(),
                  const Spacer(),
                  _buildSubmitButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildOrderInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(_order!.playerAvatar),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _order!.playerName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_order!.serviceType} · ${_order!.duration}小时',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '服务评分',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              onPressed: () {
                setState(() {
                  _rating = index + 1;
                });
              },
              icon: Icon(
                index < _rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 36,
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            _getRatingText(_rating),
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '服务标签',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (_) => _toggleTag(tag),
              backgroundColor: Colors.grey.withValues(alpha: 0.1),
              selectedColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '详细评价',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: _commentController,
          hintText: '分享您的体验...',
          maxLines: 4,
          labelText: '详细评价',
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return CustomButton(
      text: '提交评价',
      onPressed: _isSubmitting ? null : _submitRating,
      isLoading: _isSubmitting,
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return '非常不满意';
      case 2:
        return '不满意';
      case 3:
        return '一般';
      case 4:
        return '满意';
      case 5:
        return '非常满意';
      default:
        return '';
    }
  }
}
