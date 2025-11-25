package com.playmate.repository;

import com.playmate.entity.User;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import jakarta.persistence.LockModeType;
import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    // 基础查询方法
    Optional<User> findByUsername(String username);
    
    @Cacheable(value = "users", key = "#phone")
    Optional<User> findByPhone(String phone);
    
    @Cacheable(value = "users", key = "#email")
    Optional<User> findByEmail(String email);
    
    boolean existsByUsername(String username);
    boolean existsByPhone(String phone);
    boolean existsByEmail(String email);
    
    // 优化搜索查询，添加分页和索引提示
    // @Query("SELECT u FROM User u WHERE " +
    //        "LOWER(u.username) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
    //        "LOWER(u.nickname) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
    //        "ORDER BY u.createdAt DESC")
    // List<User> searchUsers(@Param("keyword") String keyword);
    List<User> searchUsers(@Param("keyword") String keyword);
    
    // 高频查询优化：获取活跃用户
    @Query("SELECT u FROM User u WHERE u.status = 'ACTIVE' AND u.userType = :userType")
    @Cacheable(value = "users", key = "#userType")
    List<User> findActiveUsersByType(@Param("userType") User.UserType userType);
    
    // 统计查询优化
    @Query("SELECT COUNT(u) FROM User u WHERE u.status = 'ACTIVE'")
    long countActiveUsers();
    
    // 批量查询优化
    @Query("SELECT u FROM User u WHERE u.id IN :ids")
    List<User> findByIdIn(@Param("ids") List<Long> ids);
    
    // 悲观锁查询（用于并发控制）
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT u FROM User u WHERE u.id = :id")
    Optional<User> findByIdWithLock(@Param("id") Long id);
    
    // 分页查询方法
    Page<User> findByUsernameContainingOrNicknameContaining(String username, String nickname, Pageable pageable);
}