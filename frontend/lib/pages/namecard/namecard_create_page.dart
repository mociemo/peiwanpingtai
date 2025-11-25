import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/user_service.dart';

class NamecardCreatePage extends StatefulWidget {
  const NamecardCreatePage({super.key});

  @override
  State<NamecardCreatePage> createState() => _NamecardCreatePageState();
}

class _NamecardCreatePageState extends State<NamecardCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _realNameController = TextEditingController();
  final _idCardController = TextEditingController();
  final _introductionController = TextEditingController();
  final _priceController = TextEditingController();
  
  final List<String> _selectedSkills = [];
  final List<String> _availableSkills = [
    '王者荣耀', '英雄联盟', '和平精英', '原神', 'CS:GO',
    'DOTA2', '永劫无间', 'APEX英雄', '守望先锋', '炉石传说'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创建名片'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 基本信息
              _buildSectionHeader('基本信息'),
              _buildTextField('真实姓名', _realNameController, '请输入真实姓名'),
              _buildTextField('身份证号', _idCardController, '请输入身份证号'),
              
              // 服务信息
              _buildSectionHeader('服务信息'),
              _buildTextField('服务价格（元/小时）', _priceController, '请输入服务价格', keyboardType: TextInputType.number),
              
              // 技能标签
              _buildSectionHeader('技能标签'),
              _buildSkillsSelection(),
              
              // 个人介绍
              _buildSectionHeader('个人介绍'),
              _buildIntroductionField(),
              
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '请输入$label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSkillsSelection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableSkills.map((skill) {
        final isSelected = _selectedSkills.contains(skill);
        return FilterChip(
          label: Text(skill),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedSkills.add(skill);
              } else {
                _selectedSkills.remove(skill);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildIntroductionField() {
    return TextFormField(
      controller: _introductionController,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: '请介绍一下您的游戏经历、擅长英雄、服务特色等',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入个人介绍';
        }
        if (value.length < 20) {
          return '个人介绍至少20字';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitNamecard,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          '提交审核',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  void _submitNamecard() async {
    if (_formKey.currentState!.validate()) {
      try {
        // 构建请求数据
        final requestData = {
          'realName': _realNameController.text.trim(),
          'idCard': _idCardController.text.trim(),
          'introduction': _introductionController.text.trim(),
          'price': double.tryParse(_priceController.text) ?? 0.0,
          'skills': _selectedSkills,
        };
        
        // 调用API创建名片
        await UserService.applyForPlayer(requestData: requestData);
        
        // 提交成功
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('名片提交成功，等待审核')),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('提交失败: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _realNameController.dispose();
    _idCardController.dispose();
    _introductionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}