package com.playmate.config;

import com.playmate.entity.User;
import com.playmate.entity.User.UserStatus;
import com.playmate.entity.User.UserType;
import com.playmate.entity.User.Gender;
import com.playmate.entity.GameCategory;
import com.playmate.entity.Activity;
import com.playmate.entity.Activity.ActivityType;
import com.playmate.entity.Activity.ActivityStatus;
import com.playmate.entity.Feedback;
import com.playmate.entity.Feedback.FeedbackStatus;
import com.playmate.repository.UserRepository;
import com.playmate.repository.GameCategoryRepository;
import com.playmate.repository.ActivityRepository;
import com.playmate.repository.FeedbackRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.lang.NonNull;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Component
@RequiredArgsConstructor
@Slf4j
@SuppressWarnings("null")
public class DataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final GameCategoryRepository gameCategoryRepository;
    private final ActivityRepository activityRepository;
    private final FeedbackRepository feedbackRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        initializeUsers();
        initializeGameCategories();
        initializeActivities();
        initializeFeedbacks();
        log.info("Data initialization completed");
    }
    
    private void initializeUsers() {
        if (userRepository.count() == 0) {
            // 从环境变量读取管理员配置，提高安全性
            String adminUsername = getRequiredEnvVar("ADMIN_USERNAME", "admin");
            String adminPassword = getRequiredEnvVar("ADMIN_PASSWORD", generateSecurePassword());
            String adminEmail = getRequiredEnvVar("ADMIN_EMAIL", "admin@playmate.com");
            
            // 确保关键参数不为空
            if (adminUsername == null || adminPassword == null || adminEmail == null) {
                throw new IllegalStateException("管理员配置参数不能为空");
            }
            
            // 验证管理员密码强度
            validatePasswordStrength(adminPassword);
            
            // 创建管理员用户
            User admin = createSecureUser(
                adminUsername, 
                adminPassword, 
                adminEmail, 
                generateSecurePhone(),
                "系统管理员",
                UserType.ADMIN,
                Gender.MALE
            );
            userRepository.save(admin);
            
            // 仅在非生产环境创建演示数据
            if (!isProductionEnvironment()) {
                createDemoUsers();
            }
            
            log.info("Created admin user: {}. Demo users created: {}", adminUsername, !isProductionEnvironment());
        }
    }
    
    private String getRequiredEnvVar(String key, String defaultValue) {
        String value = System.getenv(key);
        if (value == null || value.trim().isEmpty()) {
            log.warn("Environment variable {} not set, using default value", key);
            return defaultValue;
        }
        return value.trim();
    }
    
    private String generateSecurePassword() {
        // 生成强密码：至少12位，包含大小写字母、数字和特殊字符
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*";
        StringBuilder password = new StringBuilder();
        for (int i = 0; i < 16; i++) {
            password.append(chars.charAt((int) (Math.random() * chars.length())));
        }
        return password.toString();
    }
    
    private void validatePasswordStrength(String password) {
        if (password.length() < 8) {
            throw new IllegalArgumentException("管理员密码长度至少8位");
        }
        if (!password.matches(".*[A-Z].*")) {
            throw new IllegalArgumentException("管理员密码必须包含大写字母");
        }
        if (!password.matches(".*[a-z].*")) {
            throw new IllegalArgumentException("管理员密码必须包含小写字母");
        }
        if (!password.matches(".*\\d.*")) {
            throw new IllegalArgumentException("管理员密码必须包含数字");
        }
    }
    
    private String generateSecurePhone() {
        // 生成更安全的手机号格式
        return "138" + String.format("%08d", (int)(Math.random() * 100000000));
    }
    
    private boolean isProductionEnvironment() {
        String env = System.getenv("SPRING_PROFILES_ACTIVE");
        return "prod".equals(env) || "production".equals(env);
    }
    
    private void createDemoUsers() {
        // 创建演示用户
        User demoUser = createSecureUser(
            "demo_user", 
            "Demo123456!", 
            "demo@playmate.com", 
            generateSecurePhone(),
            "演示用户",
            UserType.USER,
            Gender.MALE
        );
        userRepository.save(demoUser);
        
        // 创建演示陪玩达人
        User demoPlayer = createSecureUser(
            "demo_player", 
            "Demo123456!", 
            "player@playmate.com", 
            generateSecurePhone(),
            "演示陪玩达人",
            UserType.PLAYER,
            Gender.FEMALE
        );
        userRepository.save(demoPlayer);
    }
    
    @NonNull
    private User createSecureUser(@NonNull String username, @NonNull String password, String email, 
                                String phone, String nickname, @NonNull UserType userType, @NonNull Gender gender) {
        User user = new User();
        user.setUsername(username);
        user.setPassword(passwordEncoder.encode(password));
        user.setEmail(email);
        user.setPhone(phone);
        user.setNickname(nickname);
        user.setUserType(userType);
        user.setStatus(UserStatus.ACTIVE);
        user.setGender(gender);
        user.setCreatedAt(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());
        return user;
    }
    
    private void initializeGameCategories() {
        if (gameCategoryRepository.count() == 0) {
            createDefaultGameCategories();
            log.info("Created default game categories");
        }
    }
    
    @SuppressWarnings("null")
    private void createDefaultGameCategories() {
        GameCategory[] categories = {
            createGameCategory("王者荣耀", "热门MOBA手游，5v5团队竞技", "/games/wangzhe.jpg", 1),
            createGameCategory("和平精英", "战术竞技射击游戏", "/games/heping.jpg", 2),
            createGameCategory("英雄联盟", "经典MOBA端游", "/games/lol.jpg", 3),
            createGameCategory("绝地求生", "大逃杀射击游戏", "/games/pubg.jpg", 4),
            createGameCategory("原神", "开放世界冒险游戏", "/games/yuanshen.jpg", 5),
            createGameCategory("金铲铲之战", "云顶之弈手游版", "/games/jinchan.jpg", 6),
            createGameCategory("永劫无间", "武侠竞技游戏", "/games/yongjie.jpg", 7),
            createGameCategory("CS:GO", "经典FPS射击游戏", "/games/csgo.jpg", 8)
        };
        
        for (GameCategory category : categories) {
            gameCategoryRepository.save(category);
        }
    }
    
    private GameCategory createGameCategory(String name, String description, String iconUrl, int sortOrder) {
        GameCategory category = new GameCategory();
        category.setName(name);
        category.setDescription(description);
        category.setIconUrl(iconUrl);
        category.setSortOrder(sortOrder);
        category.setStatus(GameCategory.CategoryStatus.ACTIVE);
        return category;
    }
    
    private void initializeActivities() {
        if (activityRepository.count() == 0) {
            createDefaultActivities();
            log.info("Created default activities");
        }
    }
    
    @SuppressWarnings("null")
    private void createDefaultActivities() {
        Activity[] activities = {
            createActivity(
                "新用户专享优惠", 
                "首次下单享受8折优惠，最高减20元", 
                "/activities/newuser.jpg", 
                ActivityType.DISCOUNT, 
                ActivityStatus.ACTIVE,
                LocalDateTime.now(),
                LocalDateTime.now().plusDays(30),
                0.8000,
                10.00,
                20.00,
                1000,
                1
            ),
            createActivity(
                "周末双倍积分", 
                "周末下单获得双倍积分奖励", 
                "/activities/weekend.jpg", 
                ActivityType.BONUS, 
                ActivityStatus.ACTIVE,
                LocalDateTime.now(),
                LocalDateTime.now().plusDays(7),
                null,
                null,
                null,
                500,
                2
            ),
            createActivity(
                "限时秒杀", 
                "指定陪玩达人限时5折优惠", 
                "/activities/seckill.jpg", 
                ActivityType.LIMITED_TIME, 
                ActivityStatus.DRAFT,
                LocalDateTime.now().plusDays(1),
                LocalDateTime.now().plusDays(2),
                0.5000,
                50.00,
                100.00,
                200,
                3
            )
        };
        
        for (Activity activity : activities) {
            activityRepository.save(activity);
        }
    }
    
    private Activity createActivity(String title, String description, String imageUrl, 
                                  ActivityType type, ActivityStatus status, 
                                  LocalDateTime startTime, LocalDateTime endTime,
                                  Double discountRate, Double minAmount, Double maxDiscount,
                                  Integer participantLimit, int sortOrder) {
        Activity activity = new Activity();
        activity.setTitle(title);
        activity.setDescription(description);
        activity.setImageUrl(imageUrl);
        activity.setType(type);
        activity.setStatus(status);
        activity.setStartTime(startTime);
        activity.setEndTime(endTime);
        if (discountRate != null) {
            activity.setDiscountRate(java.math.BigDecimal.valueOf(discountRate));
        }
        if (minAmount != null) {
            activity.setMinAmount(java.math.BigDecimal.valueOf(minAmount));
        }
        if (maxDiscount != null) {
            activity.setMaxDiscount(java.math.BigDecimal.valueOf(maxDiscount));
        }
        activity.setParticipantLimit(participantLimit);
        activity.setSortOrder(sortOrder);
        return activity;
    }
    
    private void initializeFeedbacks() {
        if (feedbackRepository.count() == 0) {
            createDefaultFeedbacks();
            log.info("Created default feedbacks");
        }
    }
    
    private void createDefaultFeedbacks() {
        Feedback[] feedbacks = {
            createFeedback(1L, "suggestion", "建议增加语音通话功能", "13800138001", FeedbackStatus.RESOLVED, "感谢您的建议，语音通话功能已在开发中"),
            createFeedback(2L, "bug", "聊天消息发送失败", "13800138002", FeedbackStatus.PROCESSING, null),
            createFeedback(3L, "complaint", "陪玩达人服务态度不好", "13800138003", FeedbackStatus.PENDING, null),
            createFeedback(1L, "other", "希望能添加更多游戏分类", "13800138001", FeedbackStatus.PENDING, null)
        };
        
        for (Feedback feedback : feedbacks) {
            feedbackRepository.save(feedback);
        }
    }
    
    private Feedback createFeedback(Long userId, String type, String content, String contact, 
                                   FeedbackStatus status, String adminReply) {
        Feedback feedback = new Feedback();
        feedback.setUserId(userId);
        feedback.setType(type);
        feedback.setContent(content);
        feedback.setContact(contact);
        feedback.setStatus(status);
        feedback.setAdminReply(adminReply);
        feedback.setCreatedAt(LocalDateTime.now());
        feedback.setUpdatedAt(LocalDateTime.now());
        return feedback;
    }
}