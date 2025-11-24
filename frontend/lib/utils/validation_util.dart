import 'package:flutter/material.dart';

class ValidationUtil {
  /// 验证手机号
  static bool isValidPhone(String phone) {
    if (phone.isEmpty) return false;
    
    // 中国大陆手机号正则表达式
    final regex = RegExp(r'^1[3-9]\d{9}$');
    return regex.hasMatch(phone);
  }

  /// 验证邮箱
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  /// 验证密码强度
  static bool isValidPassword(String password) {
    if (password.isEmpty) return false;
    
    // 至少8位，包含字母和数字
    if (password.length < 8) return false;
    
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    
    return hasLetter && hasNumber;
  }

  /// 验证密码强度等级
  static PasswordStrength getPasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.empty;
    if (password.length < 6) return PasswordStrength.weak;
    
    int score = 0;
    
    // 长度评分
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    
    // 字符类型评分
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
    
    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  /// 验证用户名
  static bool isValidUsername(String username) {
    if (username.isEmpty) return false;
    
    // 4-20位，只能包含字母、数字、下划线、中文
    final regex = RegExp(r'^[\w\u4e00-\u9fa5]{4,20}$');
    return regex.hasMatch(username);
  }

  /// 验证身份证号
  static bool isValidIdCard(String idCard) {
    if (idCard.isEmpty) return false;
    
    // 18位身份证号正则表达式
    final regex = RegExp(r'^[1-9]\d{5}(18|19|20)\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])\d{3}[\dXx]$');
    return regex.hasMatch(idCard);
  }

  /// 验证银行卡号
  static bool isValidBankCard(String bankCard) {
    if (bankCard.isEmpty) return false;
    
    // 银行卡号正则表达式（16-19位数字）
    final regex = RegExp(r'^\d{16,19}$');
    return regex.hasMatch(bankCard);
  }

  /// 验证金额
  static bool isValidAmount(String amount) {
    if (amount.isEmpty) return false;
    
    final regex = RegExp(r'^\d+(\.\d{1,2})?$');
    return regex.hasMatch(amount);
  }

  /// 验证URL
  static bool isValidUrl(String url) {
    if (url.isEmpty) return false;
    
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// 验证IP地址
  static bool isValidIp(String ip) {
    if (ip.isEmpty) return false;
    
    final regex = RegExp(r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$');
    return regex.hasMatch(ip);
  }

  /// 验证年龄
  static bool isValidAge(int age) {
    return age >= 0 && age <= 150;
  }

  /// 验证价格范围
  static bool isValidPriceRange(double minPrice, double maxPrice) {
    return minPrice >= 0 && maxPrice > minPrice;
  }

  /// 验证QQ号
  static bool isValidQQ(String qq) {
    if (qq.isEmpty) return false;
    
    final regex = RegExp(r'^[1-9][0-9]{4,10}$');
    return regex.hasMatch(qq);
  }

  /// 验证微信号
  static bool isValidWeChat(String wechat) {
    if (wechat.isEmpty) return false;
    
    // 微信号规则：6-20位，只能包含字母、数字、下划线、减号，必须以字母开头
    final regex = RegExp(r'^[a-zA-Z][a-zA-Z0-9_-]{5,19}$');
    return regex.hasMatch(wechat);
  }

  /// 验证游戏ID
  static bool isValidGameId(String gameId) {
    if (gameId.isEmpty) return false;
    
    // 游戏ID规则：3-20位，只能包含字母、数字、下划线
    final regex = RegExp(r'^[a-zA-Z0-9_]{3,20}$');
    return regex.hasMatch(gameId);
  }

  /// 验证文件大小
  static bool isValidFileSize(int fileSize, int maxSizeInBytes) {
    return fileSize > 0 && fileSize <= maxSizeInBytes;
  }

  /// 验证文件类型
  static bool isValidFileType(String fileName, List<String> allowedExtensions) {
    if (fileName.isEmpty) return false;
    
    final extension = fileName.split('.').last.toLowerCase();
    return allowedExtensions.contains(extension);
  }

  /// 验证评分
  static bool isValidRating(double rating) {
    return rating >= 0 && rating <= 5;
  }

  /// 验证评分数量
  static bool isValidRatingCount(int count) {
    return count >= 0;
  }

  /// 获取验证错误信息
  static String getValidationMessage(String field, String value) {
    switch (field.toLowerCase()) {
      case 'phone':
        if (!isValidPhone(value)) return '请输入正确的手机号';
        break;
      case 'email':
        if (!isValidEmail(value)) return '请输入正确的邮箱地址';
        break;
      case 'password':
        if (!isValidPassword(value)) return '密码至少8位，包含字母和数字';
        break;
      case 'username':
        if (!isValidUsername(value)) return '用户名4-20位，只能包含字母、数字、下划线、中文';
        break;
      case 'idcard':
        if (!isValidIdCard(value)) return '请输入正确的身份证号';
        break;
      case 'bankcard':
        if (!isValidBankCard(value)) return '请输入正确的银行卡号';
        break;
      case 'amount':
        if (!isValidAmount(value)) return '请输入正确的金额';
        break;
      case 'qq':
        if (!isValidQQ(value)) return '请输入正确的QQ号';
        break;
      case 'wechat':
        if (!isValidWeChat(value)) return '请输入正确的微信号';
        break;
      case 'gameid':
        if (!isValidGameId(value)) return '游戏ID3-20位，只能包含字母、数字、下划线';
        break;
    }
    return '';
  }
}

enum PasswordStrength {
  empty,
  weak,
  medium,
  strong,
}

extension PasswordStrengthExtension on PasswordStrength {
  String get displayName {
    switch (this) {
      case PasswordStrength.empty:
        return '';
      case PasswordStrength.weak:
        return '弱';
      case PasswordStrength.medium:
        return '中';
      case PasswordStrength.strong:
        return '强';
    }
  }

  String get description {
    switch (this) {
      case PasswordStrength.empty:
        return '';
      case PasswordStrength.weak:
        return '密码强度较弱，建议增加复杂度';
      case PasswordStrength.medium:
        return '密码强度中等';
      case PasswordStrength.strong:
        return '密码强度很好';
    }
  }

  Color get color {
    switch (this) {
      case PasswordStrength.empty:
        return const Color(0xFFE0E0E0);
      case PasswordStrength.weak:
        return const Color(0xFFFF5252);
      case PasswordStrength.medium:
        return const Color(0xFFFF9800);
      case PasswordStrength.strong:
        return const Color(0xFF4CAF50);
    }
  }
}