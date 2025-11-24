# 陪玩软件 - 项目架构说明

## 🏗️ 技术架构

### 前端架构
- **框架**: Flutter 3.10+
- **状态管理**: Provider
- **路由管理**: GoRouter
- **网络请求**: Dio
- **本地存储**: SharedPreferences

### 后端架构
- **框架**: Spring Boot 3.x
- **安全认证**: Spring Security + JWT
- **数据访问**: Spring Data JPA
- **数据库**: MySQL 8.0
- **实时通信**: WebSocket

## 📁 项目结构

### 前端目录结构
```
frontend/
├── lib/
│   ├── config/          # 配置文件
│   ├── models/          # 数据模型
│   ├── pages/           # 页面
│   ├── providers/       # 状态管理
│   ├── services/        # 服务层
│   ├── utils/           # 工具类
│   └── widgets/         # 自定义组件
```

### 后端目录结构
```
backend/
├── src/main/java/com/playmate/
│   ├── controller/      # 控制器层
│   ├── service/         # 业务逻辑层
│   ├── repository/      # 数据访问层
│   ├── entity/          # 实体类
│   ├── dto/             # 数据传输对象
│   └── config/          # 配置类
```

## 🔄 业务流程

### 用户认证流程
1. 用户输入账号密码
2. 前端发送登录请求
3. 后端验证并生成JWT
4. 前端保存token并更新状态

### 订单流程
1. 用户选择陪玩达人
2. 创建订单(待接单状态)
3. 陪玩达人接受订单
4. 服务完成并评价
5. 订单完成并支付

### 聊天流程
1. 用户发起聊天
2. 建立WebSocket连接
3. 实时消息传输
4. 支持文字/语音/视频

## 🗄️ 数据库设计

### 核心表结构
- users: 用户表
- players: 陪玩达人表
- orders: 订单表
- posts: 动态表
- comments: 评论表
- chats: 聊天表
- payments: 支付记录表

## 🔐 安全设计
- JWT Token认证
- 密码BCrypt加密
- API接口权限控制
- 敏感数据加密存储

## 🚀 部署架构
- 前端: Flutter打包为Web/Android/iOS应用
- 后端: Spring Boot打包为JAR部署
- 数据库: MySQL独立部署
- 文件存储: 云存储服务(如阿里云OSS)