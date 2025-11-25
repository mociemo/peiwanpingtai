package com.playmate.service;

import com.playmate.entity.User;
import com.playmate.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.lang.NonNull;
import org.springframework.lang.Nullable;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserService implements UserDetailsService {

    private final UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("用户不存在: " + username));

        return org.springframework.security.core.userdetails.User.builder()
                .username(user.getUsername())
                .password(user.getPassword())
                .authorities(Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + user.getUserType().name())))
                .accountExpired(false)
                .accountLocked(false)
                .credentialsExpired(false)
                .disabled(user.getStatus() != User.UserStatus.ACTIVE)
                .build();
    }

    public Optional<User> findByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    public Optional<User> findByPhone(String phone) {
        return userRepository.findByPhone(phone);
    }

    public User save(User user) {
        return userRepository.save(user);
    }

    public Optional<User> findById(Long id) {
        return userRepository.findById(id);
    }

    public boolean existsByUsername(String username) {
        return userRepository.existsByUsername(username);
    }

    public boolean existsByPhone(String phone) {
        return userRepository.existsByPhone(phone);
    }

    public User applyForPlayer(String username, String additionalInfo) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("用户不存在: " + username));
        
        if (user.getUserType() == User.UserType.PLAYER) {
            throw new IllegalStateException("用户已经是玩家");
        }
        
        if (user.getUserType() == User.UserType.ADMIN) {
            throw new IllegalStateException("管理员不能申请成为玩家");
        }
        
        // 设置用户类型为玩家（实际项目中可能需要审核流程）
        user.setUserType(User.UserType.PLAYER);
        
        return userRepository.save(user);
    }

    public User updateUserInfo(String username, Map<String, Object> userData) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("用户不存在: " + username));
        
        // 更新用户信息（排除敏感字段）
        if (userData.containsKey("nickname")) {
            user.setNickname((String) userData.get("nickname"));
        }
        if (userData.containsKey("email")) {
            user.setEmail((String) userData.get("email"));
        }
        if (userData.containsKey("avatar")) {
            user.setAvatar((String) userData.get("avatar"));
        }
        if (userData.containsKey("signature")) {
            user.setSignature((String) userData.get("signature"));
        }
        if (userData.containsKey("gender")) {
            String genderStr = (String) userData.get("gender");
            if (genderStr != null) {
                try {
                    user.setGender(User.Gender.valueOf(genderStr.toUpperCase()));
                } catch (IllegalArgumentException e) {
                    // 忽略无效的性别值
                }
            }
        }
        
        return userRepository.save(user);
    }

    public void saveUser(User user) {
        userRepository.save(user);
    }

    public Page<User> searchUsers(String keyword, String gameType, String skillLevel, 
                                 Double minPrice, Double maxPrice, Pageable pageable) {
        // 简单搜索实现，实际项目中可能需要更复杂的查询逻辑
        if (keyword != null && !keyword.trim().isEmpty()) {
            return userRepository.findByUsernameContainingOrNicknameContaining(keyword, keyword, pageable);
        }
        return userRepository.findAll(pageable);
    }

    public List<Map<String, Object>> searchUsers(String keyword) {
        List<User> users;
        if (keyword != null && !keyword.trim().isEmpty()) {
            users = userRepository.searchUsers(keyword);
        } else {
            users = userRepository.findAll();
        }
        
        return users.stream().map(user -> {
            Map<String, Object> userMap = new HashMap<>();
            userMap.put("id", user.getId());
            userMap.put("username", user.getUsername());
            userMap.put("nickname", user.getNickname());
            userMap.put("avatar", user.getAvatar());
            userMap.put("userType", user.getUserType());
            userMap.put("signature", user.getSignature());
            return userMap;
        }).toList();
    }

    /**
     * 注册新用户
     */
    public User registerUser(String username, String encodedPassword, String phone, String email, String nickname) {
        User user = new User();
        user.setUsername(username);
        user.setPassword(encodedPassword);
        user.setPhone(phone);
        user.setEmail(email);
        user.setNickname(nickname != null ? nickname : username);
        user.setUserType(User.UserType.USER);
        user.setStatus(User.UserStatus.ACTIVE);
        return userRepository.save(user);
    }

    /**
     * 根据用户名获取用户ID
     */
    @Nullable
    public Long getUserIdByUsername(String username) {
        return userRepository.findByUsername(username)
                .map(User::getId)
                .orElse(null);
    }
}