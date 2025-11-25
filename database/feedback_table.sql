-- 创建反馈表
CREATE TABLE IF NOT EXISTS feedback (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    type VARCHAR(50) NOT NULL COMMENT '反馈类型：bug, suggestion, complaint, other',
    content TEXT NOT NULL COMMENT '反馈内容',
    contact VARCHAR(100) COMMENT '联系方式',
    status ENUM('PENDING', 'PROCESSING', 'RESOLVED', 'REJECTED') NOT NULL DEFAULT 'PENDING' COMMENT '处理状态',
    admin_reply TEXT COMMENT '管理员回复',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_type (type),
    INDEX idx_created_at (created_at),
    INDEX idx_user_status (user_id, status),
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户反馈表';

-- 插入示例数据
INSERT INTO feedback (user_id, type, content, contact, status) VALUES
(1, 'suggestion', '建议增加语音通话功能', '13800138001', 'RESOLVED'),
(2, 'bug', '聊天消息发送失败', '13800138002', 'PROCESSING'),
(3, 'complaint', '陪玩达人服务态度不好', '13800138003', 'PENDING'),
(1, 'other', '希望能添加更多游戏分类', '13800138001', 'PENDING');