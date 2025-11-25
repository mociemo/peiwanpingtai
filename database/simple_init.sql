-- 简化的数据库初始化脚本
USE playmate_db;

-- 用户表
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE,
    nickname VARCHAR(100) NOT NULL,
    avatar VARCHAR(255),
    gender ENUM('MALE', 'FEMALE', 'UNKNOWN') DEFAULT 'UNKNOWN',
    password VARCHAR(255) NOT NULL,
    user_type ENUM('USER', 'PLAYER', 'ADMIN') DEFAULT 'USER',
    status ENUM('ACTIVE', 'INACTIVE', 'BANNED') DEFAULT 'ACTIVE',
    signature TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 陪玩人员表
CREATE TABLE IF NOT EXISTS players (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    real_name VARCHAR(50),
    id_card VARCHAR(20),
    skill_tags JSON,
    service_price DECIMAL(10,2),
    introduction TEXT,
    certification_status ENUM('PENDING', 'APPROVED', 'REJECTED') DEFAULT 'PENDING',
    total_orders INT DEFAULT 0,
    rating DECIMAL(3,2) DEFAULT 5.0,
    available_time JSON,
    status ENUM('AVAILABLE', 'BUSY', 'OFFLINE') DEFAULT 'AVAILABLE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 游戏分类表
CREATE TABLE IF NOT EXISTS game_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    icon VARCHAR(500),
    description VARCHAR(200),
    sort_order INT DEFAULT 0,
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 活动表
CREATE TABLE IF NOT EXISTS activities (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    image_url VARCHAR(500),
    type ENUM('DISCOUNT', 'BONUS', 'LIMITED_TIME') NOT NULL,
    status ENUM('DRAFT', 'ACTIVE', 'EXPIRED', 'CANCELLED') DEFAULT 'DRAFT',
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    discount_rate DECIMAL(5,4),
    min_amount DECIMAL(10,2),
    max_discount DECIMAL(10,2),
    participant_limit INT,
    participant_count INT DEFAULT 0,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);