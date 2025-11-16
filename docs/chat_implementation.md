# 即时通讯功能实现

## 概述

本文档描述了陪玩应用中即时通讯功能的实现，包括聊天、语音通话和视频通话功能。

## 功能特性

### 1. 聊天功能
- 文本消息发送和接收
- 消息状态显示（发送中、已发送、已送达、已读）
- 未读消息计数
- 会话列表管理
- 消息历史记录

### 2. 语音通话
- 语音通话发起和接收
- 通话状态管理
- 麦克风静音/取消静音
- 扬声器切换
- 通话计时

### 3. 视频通话
- 视频通话发起和接收
- 前后摄像头切换
- 摄像头开启/关闭
- 麦克风静音/取消静音
- 通话计时

## 技术架构

### 1. 前端架构

#### 模型层 (Models)
- `Message`: 消息模型，包含消息内容、类型、状态等
- `Conversation`: 会话模型，包含会话信息、最后一条消息、未读数等

#### 服务层 (Services)
- `WebSocketService`: WebSocket连接管理，处理实时消息和通话信令
- `ChatService`: 聊天API服务，处理消息发送、接收、历史记录等
- `CallService`: 通话服务，管理通话状态和信令

#### 状态管理 (Providers)
- `ChatProvider`: 聊天状态管理，管理会话列表、消息列表等

#### 页面层 (Pages)
- `ConversationsPage`: 会话列表页面
- `ChatPage`: 聊天页面
- `VoiceCallPage`: 语音通话页面
- `VideoCallPage`: 视频通话页面
- `IncomingCallPage`: 来电页面

#### 工具类 (Utils)
- `NavigatorService`: 全局导航服务，用于在Provider中导航

### 2. 后端架构

#### WebSocket服务
- 处理实时消息传输
- 管理用户在线状态
- 处理通话信令

#### REST API
- 消息发送和接收
- 会话管理
- 文件上传

## 实现细节

### 1. WebSocket连接

WebSocket连接在应用启动时建立，并保持长连接：

```dart
// 连接WebSocket
await WebSocketService.instance.connect();

// 监听消息
WebSocketService.instance.messageStream.listen((message) {
  _handleNewMessage(message);
});

// 监听事件
WebSocketService.instance.eventStream.listen((event) {
  _handleWebSocketEvent(event);
});
```

### 2. 消息发送

消息发送流程：
1. 创建临时消息，状态为"发送中"
2. 将临时消息添加到消息列表
3. 调用API发送消息
4. 根据API响应更新消息状态

```dart
// 发送文本消息
await ChatService.sendTextMessage(conversationId, content);
```

### 3. 通话流程

#### 发起通话
1. 用户点击通话按钮
2. 发送通话信令
3. 导航到通话页面
4. 等待对方响应

#### 接收通话
1. 收到通话信令
2. 显示来电页面
3. 用户选择接受或拒绝
4. 根据选择发送响应信令

#### 通话中
1. 管理通话状态
2. 处理麦克风、摄像头等控制
3. 计时通话时长
4. 处理通话结束

## 待实现功能

1. **音视频编解码**
   - 集成WebRTC或其他音视频SDK
   - 实现音视频流的采集和播放

2. **消息类型扩展**
   - 图片消息
   - 语音消息
   - 视频消息
   - 位置消息
   - 文件消息

3. **高级功能**
   - 消息撤回
   - 消息引用
   - 群聊功能
   - 消息加密

4. **性能优化**
   - 消息分页加载
   - 图片缓存
   - 音频压缩

## 注意事项

1. **网络处理**
   - 网络断开重连
   - 消息重发机制
   - 离线消息处理

2. **状态同步**
   - 多设备消息同步
   - 通话状态同步
   - 在线状态同步

3. **安全性**
   - 消息加密
   - 身份验证
   - 防止消息篡改

## 测试策略

1. **单元测试**
   - 消息模型测试
   - 服务层测试
   - 状态管理测试

2. **集成测试**
   - WebSocket连接测试
   - 消息发送接收测试
   - 通话流程测试

3. **UI测试**
   - 聊天界面测试
   - 通话界面测试
   - 交互流程测试