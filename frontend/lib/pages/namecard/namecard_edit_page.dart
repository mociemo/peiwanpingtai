import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/user_service.dart';

class NamecardEditPage extends StatefulWidget {
  final Map<String, dynamic> playerInfo;
  
  const NamecardEditPage({
    super.key,
    required this.playerInfo,
  });

  @override
  State<NamecardEditPage> createState() => _NamecardEditPageState();
}

class _NamecardEditPageState extends State<NamecardEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _introductionController = TextEditingController();
  final _priceController = TextEditingController();
  
  List<String> _selectedSkills = [];
  final List<String> _availableSkills = [
    '王者荣耀', '英雄联盟', '和平精英', '原神', 'CS:GO',
    'DOTA2', '永劫无间', 'APEX英雄', '守望先锋', '炉石传说'
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _introductionController.text = widget.playerInfo['introduction'] ?? '';
    _priceController.text = (widget.playerInfo['servicePrice'] ?? 0).toString();
    _selectedSkills = List<String>.from(widget.playerInfo['skillTags'] ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑名片'),
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
              // 基本信息（只读）
              _buildSectionHeader('基本信息'),
              _buildReadOnlyField('真实姓名', widget.playerInfo['realName'] ?? ''),
              _buildReadOnlyField('身份证号', widget.playerInfo['idCard'] ?? ''),
              
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

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
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
        onPressed: _updateNamecard,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          '更新名片',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  void _updateNamecard() async {
    if (_formKey.currentState!.validate()) {
      try {
        // 调用API更新名片
        await UserService.updatePlayerProfile({
          'introduction': _introductionController.text,
          'servicePrice': double.parse(_priceController.text),
          'skillTags': _selectedSkills,
        });
        
        // 更新成功
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('名片更新成功')),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('更新失败: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _introductionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}