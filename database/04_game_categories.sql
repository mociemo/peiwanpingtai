-- 创建游戏分类表
CREATE TABLE game_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(500),
    icon_url VARCHAR(255),
    sort_order INT NOT NULL DEFAULT 0,
    status ENUM('ACTIVE', 'INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_status (status),
    INDEX idx_sort_order (sort_order)
);

-- 插入默认游戏分类数据
INSERT INTO game_categories (name, description, icon_url, sort_order) VALUES
('王者荣耀', '热门MOBA手游，5v5团队竞技', '/games/wangzhe.jpg', 1),
('和平精英', '战术竞技射击游戏', '/games/heping.jpg', 2),
('英雄联盟', '经典MOBA端游', '/games/lol.jpg', 3),
('绝地求生', '大逃杀射击游戏', '/games/pubg.jpg', 4),
('原神', '开放世界冒险游戏', '/games/yuanshen.jpg', 5),
('金铲铲之战', '云顶之弈手游版', '/games/jinchan.jpg', 6),
('永劫无间', '武侠竞技游戏', '/games/yongjie.jpg', 7),
('CS:GO', '经典FPS射击游戏', '/games/csgo.jpg', 8);

-- 为players表添加游戏分类外键
ALTER TABLE players 
ADD COLUMN game_category_id BIGINT,
ADD INDEX idx_game_category_id (game_category_id),
ADD CONSTRAINT fk_players_game_category 
FOREIGN KEY (game_category_id) REFERENCES game_categories(id) ON DELETE SET NULL;