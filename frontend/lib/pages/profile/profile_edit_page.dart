import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/user_service.dart';

class ProfileEditPage extends StatefulWidget {
  final Map<String, dynamic> userInfo;
  
  const ProfileEditPage({
    super.key,
    required this.userInfo,
  });

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _signatureController = TextEditingController();
  final _birthdayController = TextEditingController();
  
  String? _selectedGender;
  String? _avatarUrl;
  DateTime? _selectedBirthday;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _nicknameController.text = widget.userInfo['nickname'] ?? '';
    _signatureController.text = widget.userInfo['signature'] ?? '';
    _selectedGender = widget.userInfo['gender'];
    _avatarUrl = widget.userInfo['avatar'];
    
    if (widget.userInfo['birthday'] != null) {
      _selectedBirthday = DateTime.parse(widget.userInfo['birthday']);
      _birthdayController.text = '${_selectedBirthday!.year}-${_selectedBirthday!.month.toString().padLeft(2, '0')}-${_selectedBirthday!.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑资料'),
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
            children: [
              // 头像编辑
              _buildAvatarSection(),
              
              // 基本信息
              _buildSectionHeader('基本信息'),
              _buildTextField('昵称', _nicknameController, '请输入昵称'),
              
              // 性别选择
              _buildGenderSelection(),
              
              // 生日选择
              _buildBirthdayField(),
              
              // 个性签名
              _buildSectionHeader('个性签名'),
              _buildSignatureField(),
              
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _avatarUrl != null 
                  ? NetworkImage(_avatarUrl!) 
                  : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  onPressed: _pickImage,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _pickImage,
          child: const Text('更换头像'),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
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

  Widget _buildGenderSelection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('性别'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedGender = 'MALE';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedGender == 'MALE' 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _selectedGender == 'MALE' 
                            ? Icons.radio_button_checked 
                            : Icons.radio_button_unchecked,
                          color: _selectedGender == 'MALE' 
                            ? Theme.of(context).primaryColor 
                            : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        const Text('男'),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedGender = 'FEMALE';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedGender == 'FEMALE' 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _selectedGender == 'FEMALE' 
                            ? Icons.radio_button_checked 
                            : Icons.radio_button_unchecked,
                          color: _selectedGender == 'FEMALE' 
                            ? Theme.of(context).primaryColor 
                            : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        const Text('女'),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedGender = 'UNKNOWN';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedGender == 'UNKNOWN' 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _selectedGender == 'UNKNOWN' 
                            ? Icons.radio_button_checked 
                            : Icons.radio_button_unchecked,
                          color: _selectedGender == 'UNKNOWN' 
                            ? Theme.of(context).primaryColor 
                            : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        const Text('保密'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBirthdayField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _birthdayController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: '生日',
          hintText: '请选择生日',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectBirthday,
          ),
        ),
      ),
    );
  }

  Widget _buildSignatureField() {
    return TextFormField(
      controller: _signatureController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: '请输入个性签名',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value != null && value.length > 50) {
          return '个性签名不能超过50字';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _updateProfile,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          '保存修改',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      // 上传图片并获取URL
      try {
        final imageUrl = await UserService.uploadAvatar(pickedFile.path);
        setState(() {
          _avatarUrl = imageUrl;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('头像上传失败: $e')),
          );
        }
      }
    }
  }

  void _selectBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedBirthday) {
      setState(() {
        _selectedBirthday = picked;
        _birthdayController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  void _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await UserService.updateProfile({
          'nickname': _nicknameController.text,
          'signature': _signatureController.text,
          'gender': _selectedGender,
          'birthday': _selectedBirthday?.toIso8601String(),
          'avatar': _avatarUrl,
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('资料更新成功')),
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
    _nicknameController.dispose();
    _signatureController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }
}