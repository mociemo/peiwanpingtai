# 陪玩平台 (Playmate Platform)

一个完整的陪玩服务平台，包含用户管理、订单系统、动态发布、实时聊天等功能。

## 📱 项目特性

- **用户系统**: 注册、登录、个人信息管理
- **订单系统**: 创建订单、支付、订单管理
- **动态发布**: 发布动态、点赞、评论
- **实时聊天**: WebSocket实时消息通信
- **关注系统**: 用户关注、粉丝管理
- **权限管理**: JWT认证、角色权限控制

## 🛠 技术栈

### 后端
- **框架**: Spring Boot 3
- **安全**: Spring Security + JWT
- **数据库**: MySQL 8.0 + JPA/Hibernate
- **实时通信**: WebSocket + STOMP
- **缓存**: Redis
- **构建工具**: Maven

### 前端
- **框架**: Flutter
- **语言**: Dart
- **平台**: 跨平台 (iOS/Android/Web/Desktop)

## 🚀 快速开始

### 环境要求
- Java 21+
- MySQL 8.0+
- Redis 6.0+
- Flutter 3.0+
- Maven 3.6+

### 数据库配置
1. 创建MySQL数据库：
```sql
CREATE DATABASE playmate_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

2. 更新 `backend/src/main/resources/application.yml` 中的数据库连接信息

### 后端启动
```bash
cd backend
mvn clean package -DskipTests
java -jar target/backend-0.0.1-SNAPSHOT.jar
```

服务将在 `http://localhost:8888` 启动

### 前端启动
```bash
cd frontend
flutter pub get
flutter run
```

## 📡 API文档

### 认证接口
- `POST /api/auth/register` - 用户注册
- `POST /api/auth/login` - 用户登录
- `POST /api/auth/logout` - 用户登出

### 用户接口
- `GET /api/user/profile` - 获取用户信息
- `PUT /api/user/profile` - 更新用户信息
- `GET /api/user/{userId}` - 获取指定用户信息

### 动态接口
- `GET /api/posts` - 获取动态列表
- `POST /api/posts` - 发布动态 (需要认证)
- `GET /api/posts/{postId}` - 获取动态详情
- `PUT /api/posts/{postId}` - 更新动态 (需要认证)
- `DELETE /api/posts/{postId}` - 删除动态 (需要认证)
- `POST /api/posts/{postId}/like` - 点赞动态
- `POST /api/posts/{postId}/unlike` - 取消点赞

### 订单接口
- `POST /api/orders` - 创建订单
- `GET /api/orders` - 获取订单列表
- `GET /api/orders/{orderId}` - 获取订单详情
- `PUT /api/orders/{orderId}/status` - 更新订单状态

### 聊天接口
- `GET /api/chat/history/{userId}` - 获取聊天历史
- `POST /api/chat/send` - 发送消息
- WebSocket: `/ws` - 实时消息推送

## 🔧 配置说明

### JWT配置
```yaml
jwt:
  secret: your-secret-key
  expiration: 86400000  # 24小时
```

### 数据库配置
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/playmate_db
    username: root
    password: your-password
```

## 🧪 测试

### API测试
运行测试脚本：
```bash
# 测试发布动态功能
powershell -ExecutionPolicy Bypass -File test_post_creation.ps1

# 完整API测试
powershell -ExecutionPolicy Bypass -File api_test.ps1
```

### 集成测试
打开 `integration_test.html` 进行Web界面测试。

## 📁 项目结构

```
playmate_app/
├── backend/                 # Spring Boot后端
│   ├── src/main/java/      # Java源码
│   ├── src/main/resources/ # 配置文件
│   └── pom.xml            # Maven配置
├── frontend/              # Flutter前端
│   ├── lib/              # Dart源码
│   ├── android/          # Android平台代码
│   ├── ios/              # iOS平台代码
│   └── pubspec.yaml      # Flutter依赖
├── database/             # 数据库脚本
├── docs/                # 项目文档
└── README.md           # 项目说明
```

## 🔐 权限配置

### 公开接口 (无需认证)
- 获取动态列表和详情
- 用户注册和登录
- 获取公开用户信息

### 需要认证的接口
- 发布、更新、删除动态
- 创建和管理订单
- 发送消息
- 用户信息修改

## 🐛 已知问题

- WebSocket连接在某些网络环境下可能不稳定
- 图片上传功能需要配置文件存储服务
- 支付功能需要集成第三方支付接口

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 📞 联系方式

如有问题或建议，请通过以下方式联系：

- 项目地址: https://github.com/mociemo/peiwanpingtai
- 问题反馈: https://github.com/mociemo/peiwanpingtai/issues

---

⭐ 如果这个项目对你有帮助，请给个Star支持一下！