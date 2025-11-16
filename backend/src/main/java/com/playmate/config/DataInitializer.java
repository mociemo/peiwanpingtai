package com.playmate.config;

import com.playmate.entity.Player;
import com.playmate.entity.User;
import com.playmate.repository.PlayerRepository;
import com.playmate.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;

@Component
public class DataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PlayerRepository playerRepository;
    private final PasswordEncoder passwordEncoder;
    
    private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(DataInitializer.class);

    public DataInitializer(UserRepository userRepository, PlayerRepository playerRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.playerRepository = playerRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) throws Exception {
        // 检查是否已存在admin用户
        if (userRepository.findByUsername("admin").isEmpty()) {
            log.info("创建默认管理员用户...");
            
            User adminUser = new User();
            adminUser.setUsername("admin");
            adminUser.setPassword(passwordEncoder.encode("123456"));
            adminUser.setNickname("系统管理员");
            adminUser.setPhone("13800000000");
            adminUser.setEmail("admin@playmate.com");
            adminUser.setUserType(User.UserType.ADMIN);
            adminUser.setStatus(User.UserStatus.ACTIVE);
            adminUser.setSignature("系统管理员账户");
            adminUser.setGender(User.Gender.MALE);
            
            userRepository.save(adminUser);
            log.info("管理员用户创建成功 - 用户名: admin, 密码: 123456");
        } else {
            log.info("管理员用户已存在");
        }

        // 检查是否已存在测试用户
        if (userRepository.findByUsername("testuser").isEmpty()) {
            log.info("创建测试用户...");
            
            User testUser = new User();
            testUser.setUsername("testuser");
            testUser.setPassword(passwordEncoder.encode("123456"));
            testUser.setNickname("测试用户");
            testUser.setPhone("13900000000");
            testUser.setEmail("test@playmate.com");
            testUser.setUserType(User.UserType.USER);
            testUser.setStatus(User.UserStatus.ACTIVE);
            testUser.setSignature("这是一个测试用户");
            testUser.setGender(User.Gender.FEMALE);
            
            userRepository.save(testUser);
            log.info("测试用户创建成功 - 用户名: testuser, 密码: 123456");
        }

        // 检查是否已存在测试陪玩达人
        if (userRepository.findByUsername("player1").isEmpty()) {
            log.info("创建测试陪玩达人...");
            
            User playerUser = new User();
            playerUser.setUsername("player1");
            playerUser.setPassword(passwordEncoder.encode("123456"));
            playerUser.setNickname("王者荣耀大神");
            playerUser.setPhone("13600000000");
            playerUser.setEmail("player1@playmate.com");
            playerUser.setUserType(User.UserType.PLAYER);
            playerUser.setStatus(User.UserStatus.ACTIVE);
            playerUser.setSignature("专业王者荣耀陪玩，带你上分！");
            playerUser.setGender(User.Gender.MALE);
            
            User savedPlayerUser = userRepository.save(playerUser);
            
            // 创建对应的Player记录
            Player player = new Player();
            player.setUser(savedPlayerUser);
            player.setRealName("张三");
            player.setIdCard("110101199001011234");
            player.setSkillTags("[\"王者荣耀\", \"上分陪玩\", \"语音指导\"]");
            player.setServicePrice(BigDecimal.valueOf(30.00));
            player.setIntroduction("专业王者荣耀陪玩，拥有5年游戏经验，擅长多个英雄，能够提供专业的游戏指导和陪玩服务。");
            player.setCertificationStatus(Player.CertificationStatus.APPROVED);
            player.setTotalOrders(128);
            player.setRating(BigDecimal.valueOf(4.9));
            player.setAvailableTime("[\"周一至周五 19:00-23:00\", \"周末 10:00-24:00\"]");
            
            playerRepository.save(player);
            log.info("陪玩达人用户创建成功 - 用户名: player1, 密码: 123456");
        }
    }
}