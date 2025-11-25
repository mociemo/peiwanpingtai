import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'help_detail_page.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('帮助中心'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSearchBar(),
          const SizedBox(height: 24),
          _buildQuickHelpSection(),
          const SizedBox(height: 24),
          _buildFAQSection(),
          const SizedBox(height: 24),
          _buildContactSection(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        decoration: const InputDecoration(
          hintText: '搜索帮助内容...',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onSubmitted: (value) {
          // 实现搜索功能
        },
      ),
    );
  }

  Widget _buildQuickHelpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快速帮助',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildHelpCard(
              Icons.account_circle,
              '账号问题',
              '登录、注册、密码重置等',
              () => _showHelpContent('账号问题'),
            ),
            _buildHelpCard(
              Icons.payment,
              '支付问题',
              '充值、提现、账单等',
              () => _showHelpContent('支付问题'),
            ),
            _buildHelpCard(
              Icons.shopping_cart,
              '订单问题',
              '下单、接单、退款等',
              () => _showHelpContent('订单问题'),
            ),
            _buildHelpCard(
              Icons.chat,
              '聊天问题',
              '消息、通话、好友等',
              () => _showHelpContent('聊天问题'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHelpCard(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    final faqs = [
      {
        'question': '如何成为陪玩达人？',
        'answer': '您可以在个人资料页面申请成为陪玩达人，需要完成实名认证和技能认证。',
      },
      {
        'question': '如何充值？',
        'answer': '进入钱包页面，点击充值按钮，选择支付方式完成充值。',
      },
      {
        'question': '如何提现？',
        'answer': '在钱包页面点击提现，填写提现信息，审核通过后即可到账。',
      },
      {
        'question': '订单纠纷如何处理？',
        'answer': '请联系客服，提供订单号和相关证据，我们会尽快处理。',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '常见问题',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...faqs.map((faq) => _buildFAQItem(faq['question']!, faq['answer']!)),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '联系我们',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('客服热线'),
                subtitle: const Text('400-123-4567'),
                onTap: () => _launchPhone('4001234567'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('客服邮箱'),
                subtitle: const Text('support@playmate.com'),
                onTap: () => _launchEmail('support@playmate.com'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.message),
                title: const Text('在线客服'),
                subtitle: const Text('工作时间 9:00-22:00'),
                onTap: () => _startOnlineChat(),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.public),
                title: const Text('官方网站'),
                subtitle: const Text('www.playmate.com'),
                onTap: () => _launchUrl('https://www.playmate.com'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showHelpContent(String category) {
    // 导航到具体的帮助内容页面
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HelpDetailPage(category: category),
      ),
    );
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _startOnlineChat() {
    // 这里可以导航到在线客服页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在连接在线客服...')),
    );
  }
}