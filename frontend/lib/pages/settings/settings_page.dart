import 'package:flutter/material.dart' hide ThemeMode;
import '../../models/app_settings_model.dart';
import '../../services/settings_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_radio_tile.dart';
import '../../utils/provider_helper.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  AppSettings? _settings;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = ProviderHelper.getCurrentUserId(context);
      
      final settings = await SettingsService.getUserSettings(userId);
      setState(() {
        _settings = settings;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSettings({
    bool? pushNotificationEnabled,
    Map<NotificationType, bool>? notificationTypes,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? inAppNotificationEnabled,
    bool? profilePublic,
    bool? showOnlineStatus,
    bool? allowStrangerMessage,
    bool? allowFollowRequest,
    AppThemeMode? themeMode,
    double? fontSize,
    bool? autoPlayVideo,
    bool? highQualityImage,
    bool? autoUpdate,
    String? language,
    bool? cacheEnabled,
    int? cacheSize,
  }) async {
    if (_settings == null) return;

    try {
      final userId = ProviderHelper.getCurrentUserId(context);
      
      final updatedSettings = await SettingsService.updateUserSettings(
        userId,
        pushNotificationEnabled: pushNotificationEnabled,
        notificationTypes: notificationTypes,
        soundEnabled: soundEnabled,
        vibrationEnabled: vibrationEnabled,
        inAppNotificationEnabled: inAppNotificationEnabled,
        profilePublic: profilePublic,
        showOnlineStatus: showOnlineStatus,
        allowStrangerMessage: allowStrangerMessage,
        allowFollowRequest: allowFollowRequest,
        themeMode: themeMode,
        fontSize: fontSize,
        autoPlayVideo: autoPlayVideo,
        highQualityImage: highQualityImage,
        autoUpdate: autoUpdate,
        language: language,
        cacheEnabled: cacheEnabled,
        cacheSize: cacheSize,
      );

      setState(() {
        _settings = updatedSettings;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('设置已保存')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存设置失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget();
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('加载失败: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSettings,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_settings == null) {
      return const Center(child: Text('设置加载失败'));
    }

    return ListView(
      children: [
        _buildNotificationSection(),
        _buildPrivacySection(),
        _buildDisplaySection(),
        _buildOtherSection(),
        _buildActionSection(),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return _buildSection(
      title: '通知设置',
      children: [
        SwitchListTile(
          title: const Text('推送通知'),
          subtitle: const Text('允许应用发送推送通知'),
          value: _settings!.pushNotificationEnabled,
          onChanged: (value) => _updateSettings(pushNotificationEnabled: value),
        ),
        SwitchListTile(
          title: const Text('声音提醒'),
          subtitle: const Text('新消息时播放声音'),
          value: _settings!.soundEnabled,
          onChanged: (value) => _updateSettings(soundEnabled: value),
        ),
        SwitchListTile(
          title: const Text('振动提醒'),
          subtitle: const Text('新消息时振动提醒'),
          value: _settings!.vibrationEnabled,
          onChanged: (value) => _updateSettings(vibrationEnabled: value),
        ),
        SwitchListTile(
          title: const Text('应用内通知'),
          subtitle: const Text('在应用内显示通知'),
          value: _settings!.inAppNotificationEnabled,
          onChanged: (value) => _updateSettings(inAppNotificationEnabled: value),
        ),
        ListTile(
          title: const Text('通知类型'),
          subtitle: const Text('设置各类通知的开关'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showNotificationTypesDialog(),
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return _buildSection(
      title: '隐私设置',
      children: [
        SwitchListTile(
          title: const Text('公开个人资料'),
          subtitle: const Text('允许其他用户查看你的个人资料'),
          value: _settings!.profilePublic,
          onChanged: (value) => _updateSettings(profilePublic: value),
        ),
        SwitchListTile(
          title: const Text('显示在线状态'),
          subtitle: const Text('让其他用户看到你的在线状态'),
          value: _settings!.showOnlineStatus,
          onChanged: (value) => _updateSettings(showOnlineStatus: value),
        ),
        SwitchListTile(
          title: const Text('允许陌生人消息'),
          subtitle: const Text('允许非关注用户发送消息'),
          value: _settings!.allowStrangerMessage,
          onChanged: (value) => _updateSettings(allowStrangerMessage: value),
        ),
        SwitchListTile(
          title: const Text('允许关注请求'),
          subtitle: const Text('允许其他用户发送关注请求'),
          value: _settings!.allowFollowRequest,
          onChanged: (value) => _updateSettings(allowFollowRequest: value),
        ),
      ],
    );
  }

  Widget _buildDisplaySection() {
    return _buildSection(
      title: '显示设置',
      children: [
        ListTile(
          title: const Text('主题模式'),
          subtitle: Text(_getThemeModeText(_settings!.themeMode)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showThemeModeDialog(),
        ),
        ListTile(
          title: const Text('字体大小'),
          subtitle: Text('${_settings!.fontSize.toInt()}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showFontSizeDialog(),
        ),
        SwitchListTile(
          title: const Text('自动播放视频'),
          subtitle: const Text('自动播放视频内容'),
          value: _settings!.autoPlayVideo,
          onChanged: (value) => _updateSettings(autoPlayVideo: value),
        ),
        SwitchListTile(
          title: const Text('高质量图片'),
          subtitle: const Text('优先加载高质量图片'),
          value: _settings!.highQualityImage,
          onChanged: (value) => _updateSettings(highQualityImage: value),
        ),
      ],
    );
  }

  Widget _buildOtherSection() {
    return _buildSection(
      title: '其他设置',
      children: [
        ListTile(
          title: const Text('语言设置'),
          subtitle: Text(_getLanguageText(_settings!.language)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showLanguageDialog(),
        ),
        SwitchListTile(
          title: const Text('自动更新'),
          subtitle: const Text('自动检查并更新应用'),
          value: _settings!.autoUpdate,
          onChanged: (value) => _updateSettings(autoUpdate: value),
        ),
        SwitchListTile(
          title: const Text('启用缓存'),
          subtitle: const Text('缓存数据以提高加载速度'),
          value: _settings!.cacheEnabled,
          onChanged: (value) => _updateSettings(cacheEnabled: value),
        ),
        ListTile(
          title: const Text('缓存大小限制'),
          subtitle: Text('${_settings!.cacheSize}MB'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showCacheSizeDialog(),
        ),
      ],
    );
  }

  Widget _buildActionSection() {
    return _buildSection(
      title: '操作',
      children: [
        ListTile(
          title: const Text('清除缓存'),
          subtitle: const Text('清除应用缓存数据'),
          leading: const Icon(Icons.cleaning_services),
          onTap: _clearCache,
        ),
        ListTile(
          title: const Text('重置设置'),
          subtitle: const Text('恢复默认设置'),
          leading: const Icon(Icons.restore),
          onTap: _resetSettings,
        ),
        ListTile(
          title: const Text('导出设置'),
          subtitle: const Text('导出当前设置配置'),
          leading: const Icon(Icons.upload_file),
          onTap: _exportSettings,
        ),
        ListTile(
          title: const Text('关于应用'),
          subtitle: const Text('版本信息和帮助'),
          leading: const Icon(Icons.info),
          onTap: _showAbout,
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: children),
        ),
      ],
    );
  }

  void _showNotificationTypesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('通知类型设置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: NotificationType.values.map((type) {
            return CheckboxListTile(
              title: Text(_getNotificationTypeText(type)),
              value: _settings!.notificationTypes[type] ?? false,
              onChanged: (value) {
                if (value != null) {
                  final updatedTypes = Map<NotificationType, bool>.from(
                    _settings!.notificationTypes,
                  );
                  updatedTypes[type] = value;
                  _updateSettings(notificationTypes: updatedTypes);
                }
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showThemeModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('主题模式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values.map((mode) {
            return CustomRadioTile<AppThemeMode>(
              title: Text(_getThemeModeText(mode)),
              value: mode,
              groupValue: _settings!.themeMode,
              onChanged: (value) {
                if (value != null) {
                  _updateSettings(themeMode: value);
                }
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('字体大小'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [12.0, 14.0, 16.0, 18.0, 20.0].map((size) {
            return CustomRadioTile<double>(
              title: Text('${size.toInt()}'),
              value: size,
              groupValue: _settings!.fontSize,
              onChanged: (value) {
                if (value != null) {
                  _updateSettings(fontSize: value);
                }
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('语言设置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['zh_CN', 'en_US'].map((lang) {
            return CustomRadioTile<String>(
              title: Text(_getLanguageText(lang)),
              value: lang,
              groupValue: _settings!.language,
              onChanged: (value) {
                if (value != null) {
                  _updateSettings(language: value);
                }
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showCacheSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('缓存大小限制'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [50, 100, 200, 500].map((size) {
            return CustomRadioTile<int>(
              title: Text('${size}MB'),
              value: size,
              groupValue: _settings!.cacheSize,
              onChanged: (value) {
                if (value != null) {
                  _updateSettings(cacheSize: value);
                }
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCache() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final userId = ProviderHelper.getCurrentUserId(context);
      
      await SettingsService.clearUserCache(userId);
      
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('缓存已清除')),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('清除缓存失败: $e')),
        );
      }
    }
  }

  Future<void> _resetSettings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置设置'),
        content: const Text('确定要重置所有设置为默认值吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // 在异步操作前获取所有需要的context依赖
      // ignore: use_build_context_synchronously
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      // ignore: use_build_context_synchronously
      final userId = ProviderHelper.getCurrentUserId(context);
      
      try {
        final resetSettings = await SettingsService.resetUserSettings(userId);
        if (mounted) {
          setState(() {
            _settings = resetSettings;
          });

          // 使用已获取的scaffoldMessenger，避免再次使用context
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('设置已重置')),
          );
        }
      } catch (e) {
        if (mounted) {
          // 使用已获取的scaffoldMessenger，避免再次使用context
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('重置设置失败: $e')),
          );
        }
      }
    }
  }

  Future<void> _exportSettings() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final userId = ProviderHelper.getCurrentUserId(context);
      
      await SettingsService.exportUserSettings(userId);
      
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('设置已导出')),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('导出设置失败: $e')),
        );
      }
    }
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关于应用'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('陪玩应用'),
            SizedBox(height: 8),
            Text('版本: 1.0.0'),
            SizedBox(height: 8),
            Text('这是一个陪玩社交应用，提供游戏陪玩、社交互动等功能。'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  String _getNotificationTypeText(NotificationType type) {
    switch (type) {
      case NotificationType.system:
        return '系统通知';
      case NotificationType.order:
        return '订单通知';
      case NotificationType.message:
        return '消息通知';
      case NotificationType.follow:
        return '关注通知';
      case NotificationType.like:
        return '点赞通知';
      case NotificationType.comment:
        return '评论通知';
      case NotificationType.promotion:
        return '推广通知';
    }
  }

  String _getThemeModeText(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return '跟随系统';
      case AppThemeMode.light:
        return '浅色模式';
      case AppThemeMode.dark:
        return '深色模式';
    }
  }

  String _getLanguageText(String language) {
    switch (language) {
      case 'zh_CN':
        return '简体中文';
      case 'en_US':
        return 'English';
      default:
        return language;
    }
  }
}