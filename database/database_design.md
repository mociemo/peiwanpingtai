# 陪玩软件数据库设计

## 核心表结构

### 1. 用户表 (users)
```sql
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    phone VARCHAR(20) UNIQUE NOT NULL,      -- 手机号
    password VARCHAR(255),                  -- 密码（可为空，支持第三方登录）
    nickname VARCHAR(50) NOT NULL,          -- 昵称
    avatar VARCHAR(500),                    -- 头像URL
    gender ENUM('MALE', 'FEMALE', 'UNKNOWN'), -- 性别
    birthday DATE,                          -- 生日
    signature VARCHAR(200),                -- 个性签名
    user_type ENUM('USER', 'PLAYER', 'ADMIN'), -- 用户类型
    status ENUM('ACTIVE', 'INACTIVE', 'BANNED'), -- 状态
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### 2. 陪玩人员表 (players)
```sql
CREATE TABLE players (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    real_name VARCHAR(50),                  -- 真实姓名
    id_card VARCHAR(20),                    -- 身份证号
    skill_tags JSON,                        -- 技能标签
    service_price DECIMAL(10,2),            -- 服务价格/小时
    introduction TEXT,                      -- 个人介绍
    certification_status ENUM('PENDING', 'APPROVED', 'REJECTED'), -- 认证状态
    total_orders INT DEFAULT 0,             -- 总接单量
    rating DECIMAL(3,2) DEFAULT 5.0,       -- 评分
    available_time JSON,                    -- 可服务时间
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

### 3. 游戏分类表 (game_categories)
```sql
CREATE TABLE game_categories (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,              -- 游戏名称
    icon VARCHAR(500),                      -- 游戏图标
    description VARCHAR(200),               -- 游戏描述
    sort_order INT DEFAULT 0,               -- 排序
    status ENUM('ACTIVE', 'INACTIVE'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 4. 订单表 (orders)
```sql
CREATE TABLE orders (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_no VARCHAR(50) UNIQUE NOT NULL,   -- 订单号
    user_id BIGINT NOT NULL,                -- 用户ID
    player_id BIGINT NOT NULL,              -- 陪玩人员ID
    game_id BIGINT,                         -- 游戏ID
    service_type ENUM('HOUR', 'GAME', 'CUSTOM'), -- 服务类型
    service_time INT,                       -- 服务时长（分钟）
    total_amount DECIMAL(10,2),             -- 总金额
    status ENUM('PENDING', 'PAID', 'CONFIRMED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'REFUNDED'),
    scheduled_time DATETIME,                -- 预约时间
    actual_start_time DATETIME,             -- 实际开始时间
    actual_end_time DATETIME,               -- 实际结束时间
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (player_id) REFERENCES players(id),
    FOREIGN KEY (game_id) REFERENCES game_categories(id)
);
```

### 5. 聊天记录表 (messages)
```sql
CREATE TABLE messages (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    from_user_id BIGINT NOT NULL,           -- 发送者ID
    to_user_id BIGINT NOT NULL,             -- 接收者ID
    message_type ENUM('TEXT', 'IMAGE', 'VOICE', 'VIDEO', 'SYSTEM'),
    content TEXT,                           -- 消息内容
    file_url VARCHAR(500),                  -- 文件URL
    duration INT,                           -- 语音/视频时长
    is_read BOOLEAN DEFAULT FALSE,          -- 是否已读
    is_recalled BOOLEAN DEFAULT FALSE,      -- 是否撤回
    order_id BIGINT,                        -- 关联订单ID
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (from_user_id) REFERENCES users(id),
    FOREIGN KEY (to_user_id) REFERENCES users(id),
    FOREIGN KEY (order_id) REFERENCES orders(id)
);
```

### 6. 支付记录表 (payments)
```sql
CREATE TABLE payments (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    payment_no VARCHAR(50) UNIQUE NOT NULL,  -- 支付流水号
    user_id BIGINT NOT NULL,                -- 用户ID
    order_id BIGINT,                        -- 订单ID
    payment_type ENUM('RECHARGE', 'ORDER', 'WITHDRAW'), -- 支付类型
    amount DECIMAL(10,2) NOT NULL,          -- 金额
    payment_method ENUM('WECHAT', 'ALIPAY', 'BALANCE'), -- 支付方式
    status ENUM('PENDING', 'SUCCESS', 'FAILED', 'REFUNDED'),
    transaction_id VARCHAR(100),           -- 第三方交易ID
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (order_id) REFERENCES orders(id)
);
```

### 7. 动态表 (posts)
```sql
CREATE TABLE posts (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,                -- 发布者ID
    content TEXT,                           -- 内容
    media_urls JSON,                        -- 媒体文件URL
    post_type ENUM('TEXT', 'IMAGE', 'VIDEO'), -- 动态类型
    visibility ENUM('PUBLIC', 'FOLLOWERS', 'PRIVATE'), -- 可见性
    status ENUM('PENDING', 'APPROVED', 'REJECTED'), -- 审核状态
    like_count INT DEFAULT 0,              -- 点赞数
    comment_count INT DEFAULT 0,            -- 评论数
    share_count INT DEFAULT 0,             -- 分享数
    scheduled_time DATETIME,                -- 定时发布时间
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

## 索引设计
```sql
-- 用户表索引
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_status ON users(status);

-- 订单表索引
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_player_id ON orders(player_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);

-- 消息表索引
CREATE INDEX idx_messages_conversation ON messages(from_user_id, to_user_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);

-- 支付表索引
CREATE INDEX idx_payments_user_id ON payments(user_id);
CREATE INDEX idx_payments_status ON payments(status);
```