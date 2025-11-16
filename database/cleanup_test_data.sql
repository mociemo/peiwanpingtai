-- 清理测试数据脚本
-- 注意：此脚本将删除所有测试数据，请谨慎使用！

-- 禁用外键检查
SET FOREIGN_KEY_CHECKS = 0;

-- 清理订单相关表
DELETE FROM order_items;
DELETE FROM orders;

-- 清理社区相关表
DELETE FROM post_likes;
DELETE FROM post_comments;
DELETE FROM posts;

-- 清理聊天相关表
DELETE FROM chat_messages;

-- 清理支付相关表
DELETE FROM payment_records;
DELETE FROM recharge_records;

-- 清理用户相关表（保留管理员和测试账号）
DELETE FROM user_roles WHERE user_id NOT IN (1, 2, 3);
DELETE FROM users WHERE id NOT IN (1, 2, 3);

-- 重新启用外键检查
SET FOREIGN_KEY_CHECKS = 1;

-- 重置自增ID
ALTER TABLE orders AUTO_INCREMENT = 1;
ALTER TABLE posts AUTO_INCREMENT = 1;
ALTER TABLE chat_messages AUTO_INCREMENT = 1;
ALTER TABLE payment_records AUTO_INCREMENT = 1;
ALTER TABLE recharge_records AUTO_INCREMENT = 1;

-- 显示清理结果
SELECT '清理完成' AS status;