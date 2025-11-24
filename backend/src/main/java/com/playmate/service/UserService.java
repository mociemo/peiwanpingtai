package com.playmate.service;

import com.playmate.entity.User;
import com.playmate.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class UserService implements UserDetailsService {
    
    private final UserRepository userRepository;
    
    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("用户不存在: " + username));
        
        return new org.springframework.security.core.userdetails.User(
                user.getUsername(),
                user.getPassword(),
                Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + user.getUserType()))
        );
    }
    
    public User registerUser(String username, String encodedPassword, String email, String phone, String nickname) {
        if (userRepository.findByUsername(username).isPresent()) {
            throw new RuntimeException("用户名已存在");
        }
        
        // 如果没有提供phone，生成一个临时的
        if (phone == null || phone.isEmpty()) {
            phone = "temp_" + System.currentTimeMillis();
        }
        
        User user = new User();
        user.setUsername(username);
        user.setPassword(encodedPassword); // 接受已编码的密码
        user.setEmail(email);
        user.setPhone(phone);
        user.setNickname(nickname != null ? nickname : username);
        user.setUserType(User.UserType.USER);
        user.setStatus(User.UserStatus.ACTIVE);
        
        return userRepository.save(user);
    }
    
    public User findByUsername(String username) {
        return userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
    }
    
    public User findByPhone(String phone) {
        return userRepository.findByPhone(phone)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
    }
    
    public boolean existsByUsername(String username) {
        return userRepository.findByUsername(username).isPresent();
    }
    
    public boolean existsByPhone(String phone) {
        return userRepository.findByPhone(phone).isPresent();
    }
    
    public boolean existsByEmail(String email) {
        return userRepository.findByEmail(email).isPresent();
    }
    
    public User updateUserInfo(String username, Map<String, Object> userData) {
        User user = findByUsername(username);
        
        if (userData.containsKey("nickname")) {
            String nickname = (String) userData.get("nickname");
            if (nickname != null) {
                user.setNickname(nickname);
            }
        }
        
        if (userData.containsKey("email")) {
            String email = (String) userData.get("email");
            if (email != null && !email.equals(user.getEmail())) {
                if (existsByEmail(email)) {
                    throw new RuntimeException("邮箱已被使用");
                }
                user.setEmail(email);
            }
        }
        
        if (userData.containsKey("signature")) {
            String signature = (String) userData.get("signature");
            if (signature != null) {
                user.setSignature(signature);
            }
        }
        
        if (userData.containsKey("gender")) {
            String gender = (String) userData.get("gender");
            if (gender != null) {
                user.setGender(User.Gender.valueOf(gender));
            }
        }
        
        return userRepository.save(user);
    }
    
    public User applyForPlayer(String username) {
        User user = findByUsername(username);
        
        if (user.getUserType() == User.UserType.PLAYER) {
            throw new RuntimeException("您已经是陪玩达人");
        }
        
        user.setUserType(User.UserType.PLAYER);
        
        return userRepository.save(user);
    }
}