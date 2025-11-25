-- 创建活动表
CREATE TABLE activities (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    image_url VARCHAR(500),
    type ENUM('DISCOUNT', 'BONUS', 'LIMITED_TIME') NOT NULL,
    status ENUM('DRAFT', 'ACTIVE', 'SUSPENDED', 'ENDED', 'CANCELLED') NOT NULL DEFAULT 'DRAFT',
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    discount_rate DECIMAL(5,4),
    min_amount DECIMAL(10,2),
    max_discount DECIMAL(10,2),
    participant_limit INT,
    participant_count INT NOT NULL DEFAULT 0,
    sort_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_status (status),
    INDEX idx_type (type),
    INDEX idx_time_range (start_time, end_time),
    INDEX idx_sort_order (sort_order)
);

-- 插入示例活动数据
INSERT INTO activities (title, description, image_url, type, status, start_time, end_time, discount_rate, min_amount, max_discount, participant_limit, sort_order) VALUES
('新用户专享优惠', '首次下单享受8折优惠，最高减20元', '/activities/newuser.jpg', 'DISCOUNT', 'ACTIVE', 
 NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 0.8000, 10.00, 20.00, 1000, 1),
('周末双倍积分', '周末下单获得双倍积分奖励', '/activities/weekend.jpg', 'BONUS', 'ACTIVE', 
 NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY), NULL, NULL, NULL, 500, 2),
('限时秒杀', '指定陪玩达人限时5折优惠', '/activities/seckill.jpg', 'LIMITED_TIME', 'DRAFT', 
 DATE_ADD(NOW(), INTERVAL 1 DAY), DATE_ADD(NOW(), INTERVAL 2 DAY), 0.5000, 50.00, 100.00, 200, 3);