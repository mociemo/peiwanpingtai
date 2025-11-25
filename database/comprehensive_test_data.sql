-- 完善的测试数据
USE playmate_db;

-- 清理现有数据
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE feedback;
TRUNCATE TABLE messages;
TRUNCATE TABLE payments;
TRUNCATE TABLE wallets;
TRUNCATE TABLE orders;
TRUNCATE TABLE comments;
TRUNCATE TABLE post_tags;
TRUNCATE TABLE post_images;
TRUNCATE TABLE posts;
TRUNCATE TABLE follows;
TRUNCATE TABLE players;
TRUNCATE TABLE game_categories;
TRUNCATE TABLE users;
SET FOREIGN_KEY_CHECKS = 1;

-- 插入游戏分类数据
INSERT INTO game_categories (name, description, icon_url, sort_order, status) VALUES
('王者荣耀', '热门MOBA手游，5v5团队竞技', '/games/wangzhe.jpg', 1, 'ACTIVE'),
('和平精英', '战术竞技射击游戏', '/games/heping.jpg', 2, 'ACTIVE'),
('英雄联盟', '经典MOBA端游', '/games/lol.jpg', 3, 'ACTIVE'),
('绝地求生', '大逃杀射击游戏', '/games/pubg.jpg', 4, 'ACTIVE'),
('原神', '开放世界冒险游戏', '/games/yuanshen.jpg', 5, 'ACTIVE'),
('金铲铲之战', '云顶之弈手游版', '/games/jinchan.jpg', 6, 'ACTIVE'),
('永劫无间', '武侠竞技游戏', '/games/yongjie.jpg', 7, 'ACTIVE'),
('CS:GO', '经典FPS射击游戏', '/games/csgo.jpg', 8, 'ACTIVE'),
('崩坏：星穹铁道', '二次元回合制游戏', '/games/honkai.jpg', 9, 'ACTIVE'),
('第五人格', '非对称竞技游戏', '/games/id5.jpg', 10, 'ACTIVE');

-- 插入用户数据
INSERT INTO users (username, phone, email, nickname, avatar, gender, password, user_type, status, signature) VALUES
-- 管理员
('admin', '13800000001', 'admin@playmate.com', '系统管理员', '/avatars/admin.jpg', 'MALE', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', 'ADMIN', 'ACTIVE', '负责平台管理和维护'),

-- 陪玩达人
('player_wang', '13800000002', 'wang@playmate.com', '王者荣耀小王子', '/avatars/player1.jpg', 'MALE', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', 'PLAYER', 'ACTIVE', '国服王者，带你上分！'),
('player_li', '13800000003', 'li@playmate.com', '电竞小姐姐莉莉', '/avatars/player2.jpg', 'FEMALE', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', 'PLAYER', 'ACTIVE', '声音甜美，技术过硬'),
('player_zhang', '13800000004', 'zhang@playmate.com', '和平精英战神', '/avatars/player3.jpg', 'MALE', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', 'PLAYER', 'ACTIVE', '枪法刚，意识强，吃鸡率95%'),
('player_chen', '13800000005', 'chen@playmate.com', 'LOL钻石打野', '/avatars/player4.jpg', 'FEMALE', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', 'PLAYER', 'ACTIVE', '节奏带飞，温柔陪玩'),
('player_liu', '13800000006', 'liu@playmate.com', '原神冒险家', '/avatars/player5.jpg', 'MALE', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', 'PLAYER', 'ACTIVE', '深境螺旋满星，剧情专家'),

-- 普通用户
('user_ming', '13900000001', 'ming@test.com', '小明', '/avatars/user1.jpg', 'MALE', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', 'USER', 'ACTIVE', '游戏爱好者，喜欢结交朋友'),
('user_hong', '13900000002', 'hong@test.com', '小红', '/avatars/user2.jpg', 'FEMALE', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', 'USER', 'ACTIVE', '寻找有趣的陪玩体验'),
('user_wei', '13900000003', 'wei@test.com', '阿伟', '/avatars/user3.jpg', 'MALE', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', 'USER', 'ACTIVE', '周末玩玩游戏，放松心情'),
('user_jie', '13900000004', 'jie@test.com', '小杰', '/avatars/user4.jpg', 'MALE', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', 'USER', 'ACTIVE', '技术一般，想找大神带'),
('user_mei', '13900000005', 'mei@test.com', '小美', '/avatars/user5.jpg', 'FEMALE', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', 'USER', 'ACTIVE', '喜欢聊天，声音控');

-- 插入陪玩人员数据
INSERT INTO players (user_id, real_name, id_card, skill_tags, service_price, introduction, certification_status, total_orders, rating, available_time, status) VALUES
(2, '王某某', '110101199001011234', '["王者荣耀", "打野", "上单", "节奏"]', 80.00, '国服王者段位，擅长各种英雄，能根据队友水平调整节奏，让你轻松上分！', 'APPROVED', 156, 4.8, '["周一至周五 18:00-23:00", "周末 10:00-23:00"]', 'AVAILABLE'),
(3, '李某李', '110101199502022345', '["王者荣耀", "辅助", "中单", "语音"]', 60.00, '钻石段位，声音甜美，性格开朗，适合娱乐局和技术局', 'APPROVED', 89, 4.9, '["每天 14:00-22:00"]', 'AVAILABLE'),
(4, '张三张', '110101199303033456', '["和平精英", "狙击", "突击", "指挥"]', 70.00, '战神段位，枪法精准，战术意识强，能带你轻松吃鸡', 'APPROVED', 203, 4.7, '["周二至周日 16:00-24:00"]', 'BUSY'),
(5, '陈某某', '110101199804044567', '["英雄联盟", "打野", "上单", "教学"]', 65.00, '钻石段位，擅长打野位置，能教给你实用的游戏技巧', 'APPROVED', 124, 4.6, '["周末全天", "工作日晚上"]', 'AVAILABLE'),
(6, '刘某某', '110101200005055678', '["原神", "剧情", "深渊", "养成"]', 55.00, '60级老玩家，深境螺旋满星，能帮你解决各种游戏难题', 'APPROVED', 67, 4.9, '["每天 19:00-23:00"]', 'AVAILABLE');

-- 插入钱包数据
INSERT INTO wallets (user_id, balance, frozen_amount, total_revenue) VALUES
(1, 100000.00, 0.00, 0.00),  -- 管理员
(2, 15000.00, 2000.00, 25000.00),  -- 陪玩达人1
(3, 12000.00, 1500.00, 18000.00),  -- 陪玩达人2
(4, 18000.00, 3000.00, 32000.00),  -- 陪玩达人3
(5, 10000.00, 1000.00, 15000.00),  -- 陪玩达人4
(6, 8000.00, 800.00, 12000.00),   -- 陪玩达人5
(7, 2000.00, 0.00, 0.00),         -- 普通用户1
(8, 1500.00, 0.00, 0.00),         -- 普通用户2
(9, 3000.00, 0.00, 0.00),         -- 普通用户3
(10, 800.00, 0.00, 0.00),         -- 普通用户4
(11, 1200.00, 0.00, 0.00);        -- 普通用户5

-- 插入订单数据
INSERT INTO orders (order_no, user_id, player_id, game_id, amount, duration, status, service_type, requirements, contact_info, create_time, start_time, end_time, rating, comment, comment_time) VALUES
-- 已完成的订单
('ORD20241125001', 7, 2, 1, 80.00, 60, 'COMPLETED', 'GAME_GUIDE', '想要上分，希望能赢', '微信: test123', '2024-11-25 10:00:00', '2024-11-25 10:05:00', '2024-11-25 11:05:00', '5', '技术很好，态度也很棒！成功上星了', '2024-11-25 11:10:00'),
('ORD20241125002', 8, 3, 1, 60.00, 90, 'COMPLETED', 'ENTERTAINMENT', '娱乐局，开心就好', 'QQ: 123456', '2024-11-25 14:00:00', '2024-11-25 14:03:00', '2024-11-25 15:33:00', '5', '声音很好听，很聊得来', '2024-11-25 15:35:00'),
('ORD20241125003', 9, 4, 2, 70.00, 120, 'COMPLETED', 'GAME_GUIDE', '想吃鸡，求带飞', '微信: test456', '2024-11-25 16:00:00', '2024-11-25 16:02:00', '2024-11-25 18:02:00', '4', '技术不错，就是有点严肃', '2024-11-25 18:05:00'),
-- 进行中的订单
('ORD20241126001', 10, 5, 3, 65.00, 60, 'IN_PROGRESS', 'GAME_GUIDE', '学习打野技巧', 'QQ: 789012', '2024-11-26 09:00:00', '2024-11-26 09:01:00', NULL, NULL, NULL, NULL),
-- 待接受的订单
('ORD20241126002', 11, 6, 5, 55.00, 90, 'PENDING', 'ENTERTAINMENT', '一起探索原神世界', '微信: yuan123', '2024-11-26 11:30:00', NULL, NULL, NULL, NULL, NULL, NULL);

-- 插入支付记录数据
INSERT INTO payments (payment_no, order_id, user_id, amount, payment_type, payment_method, transaction_id, status, create_time) VALUES
-- 充值记录
('PAY20241125001', NULL, 7, 500.00, 'RECHARGE', 'WECHAT', 'WX20241125001', 'SUCCESS', '2024-11-24 10:00:00'),
('PAY20241125002', NULL, 8, 300.00, 'RECHARGE', 'ALIPAY', 'ALI20241125002', 'SUCCESS', '2024-11-24 14:00:00'),
('PAY20241125003', NULL, 9, 800.00, 'RECHARGE', 'WECHAT', 'WX20241125003', 'SUCCESS', '2024-11-25 09:00:00'),
-- 订单支付
('PAY20241125004', 1, 7, 80.00, 'ORDER', 'BALANCE', 'BAL20241125001', 'SUCCESS', '2024-11-25 10:02:00'),
('PAY20241125005', 2, 8, 60.00, 'ORDER', 'BALANCE', 'BAL20241125002', 'SUCCESS', '2024-11-25 14:02:00'),
('PAY20241125006', 3, 9, 70.00, 'ORDER', 'BALANCE', 'BAL20241125003', 'SUCCESS', '2024-11-25 16:01:00'),
('PAY20241126001', 4, 10, 65.00, 'ORDER', 'BALANCE', 'BAL20241126001', 'SUCCESS', '2024-11-26 09:00:00');

-- 插入关注关系数据
INSERT INTO follows (follower_id, following_id, create_time) VALUES
(7, 2, '2024-11-20 10:00:00'),  -- 小明关注陪玩达人1
(7, 3, '2024-11-20 10:30:00'),  -- 小明关注陪玩达人2
(8, 2, '2024-11-21 14:00:00'),  -- 小红关注陪玩达人1
(8, 3, '2024-11-21 14:30:00'),  -- 小红关注陪玩达人2
(9, 4, '2024-11-22 16:00:00'),  -- 阿伟关注陪玩达人3
(10, 5, '2024-11-23 18:00:00'), -- 小杰关注陪玩达人4
(11, 3, '2024-11-23 19:00:00'), -- 小美关注陪玩达人2
(11, 6, '2024-11-23 19:30:00'), -- 小美关注陪玩达人5
(7, 8, '2024-11-24 10:00:00'),  -- 小明关注小红（用户间关注）
(9, 7, '2024-11-24 15:00:00');  -- 阿伟关注小明

-- 插入动态数据
INSERT INTO posts (user_id, content, type, status, like_count, comment_count, share_count, is_pinned, location, game_name, create_time) VALUES
(2, '今天带了个小白兄弟，从青铜上到了白银，成就感满满！继续加油💪', 'TEXT', 'PUBLISHED', 25, 8, 3, FALSE, '线上', '王者荣耀', '2024-11-25 12:00:00'),
(3, '今天的声音状态很不错，有需要语音陪玩的小哥哥小姐姐吗？😊', 'TEXT', 'PUBLISHED', 18, 5, 1, FALSE, '家里', '王者荣耀', '2024-11-25 14:30:00'),
(4, '和平精英新地图很赞！刚带老板吃了鸡，晚上还有位置哦~', 'TEXT', 'PUBLISHED', 32, 12, 4, TRUE, '训练场', '和平精英', '2024-11-25 16:00:00'),
(7, '今天遇到了一个很棒的陪玩小姐姐，技术好声音甜，强烈推荐！', 'TEXT', 'PUBLISHED', 15, 6, 2, FALSE, '家里', '王者荣耀', '2024-11-25 18:00:00'),
(8, '第一次尝试陪玩，有点紧张但是很开心，谢谢大家的支持~', 'TEXT', 'PUBLISHED', 22, 9, 1, FALSE, '宿舍', '王者荣耀', '2024-11-25 19:30:00'),
(5, 'LOL打野教学进行中，欢迎想学习的朋友预约~', 'TEXT', 'PUBLISHED', 12, 4, 0, FALSE, '家里', '英雄联盟', '2024-11-25 20:00:00'),
(6, '原神4.0版本更新了，水之国太美了！有人要一起探索吗？', 'TEXT', 'PUBLISHED', 28, 11, 5, FALSE, '枫丹', '原神', '2024-11-25 21:00:00');

-- 插入动态图片数据
INSERT INTO post_images (post_id, image_url) VALUES
(1, '/posts/game1_1.jpg'),
(1, '/posts/game1_2.jpg'),
(3, '/posts/pubg1.jpg'),
(3, '/posts/pubg2.jpg'),
(4, '/posts/screenshot1.jpg'),
(7, '/posts/lol_teach.jpg'),
(7, '/posts/lol_result.jpg');

-- 插入动态标签数据
INSERT INTO post_tags (post_id, tag) VALUES
(1, '王者荣耀', '上分', '陪玩'),
(2, '语音', '甜美女声', '在线'),
(3, '和平精英', '吃鸡', '技术'),
(4, '体验分享', '推荐'),
(5, '新手', '感谢'),
(6, '英雄联盟', '教学', '打野'),
(7, '原神', '4.0版本', '组队');

-- 插入评论数据
INSERT INTO comments (post_id, user_id, content, parent_id, reply_to_user_id, status, like_count, create_time) VALUES
-- 对动态1的评论
(1, 7, '太强了！我也想上分', NULL, NULL, 'PUBLISHED', 5, '2024-11-25 12:15:00'),
(1, 8, '兄弟需要陪玩吗？', NULL, NULL, 'PUBLISHED', 3, '2024-11-25 12:20:00'),
(1, 7, '@小红  考虑一下，多少钱一小时？', 2, 8, 'PUBLISHED', 1, '2024-11-25 12:25:00'),
(1, 8, '@小明  60元一小时，很优惠的哦~', 3, 7, 'PUBLISHED', 2, '2024-11-25 12:30:00'),
-- 对动态2的评论
(2, 9, '声音真的很好听，已经下单了！', NULL, NULL, 'PUBLISHED', 8, '2024-11-25 14:45:00'),
(2, 10, '晚上有时间吗？想一起玩', NULL, NULL, 'PUBLISHED', 4, '2024-11-25 14:50:00'),
-- 对动态3的评论
(3, 11, '大佬带我！', NULL, NULL, 'PUBLISHED', 6, '2024-11-25 16:10:00'),
(3, 7, '什么段位呀？', NULL, NULL, 'PUBLISHED', 2, '2024-11-25 16:15:00');

-- 插入聊天消息数据
INSERT INTO messages (from_user_id, to_user_id, message_type, content, is_read, create_time) VALUES
-- 用户和陪玩达人的聊天
(7, 2, 'TEXT', '你好，请问现在有时间吗？', TRUE, '2024-11-25 09:30:00'),
(2, 7, 'TEXT', '你好！有的，现在在线', TRUE, '2024-11-25 09:32:00'),
(7, 2, 'TEXT', '想和你一起玩王者荣耀，可以吗？', TRUE, '2024-11-25 09:35:00'),
(2, 7, 'TEXT', '当然可以！直接下单就可以了', TRUE, '2024-11-25 09:36:00'),
(7, 2, 'TEXT', '好的，我马上下单', TRUE, '2024-11-25 09:40:00'),
-- 用户间的聊天
(7, 8, 'TEXT', '你好，认识一下？', TRUE, '2024-11-25 11:00:00'),
(8, 7, 'TEXT', '你好呀！你也是玩游戏的吗？', TRUE, '2024-11-25 11:05:00'),
(7, 8, 'TEXT', '是的，主要玩王者荣耀', TRUE, '2024-11-25 11:08:00'),
(8, 7, 'TEXT', '我也是！我们可以一起开黑', TRUE, '2024-11-25 11:10:00'),
-- 系统消息
(1, 7, 'SYSTEM', '您的订单已确认，陪玩达人将在5分钟内联系您', TRUE, '2024-11-25 10:00:00'),
(1, 2, 'SYSTEM', '您有新的订单，请及时处理', TRUE, '2024-11-25 10:00:00');

-- 插入反馈数据
INSERT INTO feedback (user_id, type, content, contact, status, admin_reply, create_time) VALUES
(7, 'suggestion', '建议增加更多游戏分类，比如DNF、CF等', '13800000001', 'RESOLVED', '感谢您的建议，我们会考虑在下个版本中增加更多游戏分类', '2024-11-24 15:00:00'),
(8, 'bug', '聊天消息有时候发送失败，需要重试', '13900000002', 'PROCESSING', '我们正在排查这个问题，预计本周内修复', '2024-11-24 16:30:00'),
(9, 'complaint', '有个陪玩达人态度不好，希望能处理', '13900000003', 'PENDING', NULL, '2024-11-25 10:00:00'),
(10, 'other', '希望能添加视频通话功能', '13900000004', 'PENDING', NULL, '2024-11-25 11:00:00'),
(11, 'suggestion', '界面很好看，希望能添加深色模式', '13900000005', 'RESOLVED', '感谢反馈，深色模式正在开发中', '2024-11-25 14:00:00');

-- 更新统计信息
UPDATE game_categories SET updated_at = NOW() WHERE id > 0;
UPDATE players SET updated_at = NOW() WHERE id > 0;
UPDATE posts SET update_time = NOW() WHERE id > 0;
UPDATE feedback SET update_time = NOW() WHERE id > 0;

-- 显示插入的数据统计
SELECT 'Users' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'Players', COUNT(*) FROM players
UNION ALL
SELECT 'Game Categories', COUNT(*) FROM game_categories
UNION ALL
SELECT 'Orders', COUNT(*) FROM orders
UNION ALL
SELECT 'Payments', COUNT(*) FROM payments
UNION ALL
SELECT 'Posts', COUNT(*) FROM posts
UNION ALL
SELECT 'Comments', COUNT(*) FROM comments
UNION ALL
SELECT 'Messages', COUNT(*) FROM messages
UNION ALL
SELECT 'Follows', COUNT(*) FROM follows
UNION ALL
SELECT 'Wallets', COUNT(*) FROM wallets
UNION ALL
SELECT 'Feedback', COUNT(*) FROM feedback;