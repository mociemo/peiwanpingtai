package com.playmate.repository;

import com.playmate.entity.Wallet;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import jakarta.persistence.LockModeType;
import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Repository
public interface WalletRepository extends JpaRepository<Wallet, Long> {
    
    @Cacheable(value = "wallets", key = "#userId")
    Optional<Wallet> findByUserId(Long userId);
    
    // 悲观锁查询，用于并发控制
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT w FROM Wallet w WHERE w.user.id = :userId")
    Optional<Wallet> findByUserIdWithLock(@Param("userId") Long userId);
    
    boolean existsByUserId(Long userId);
    
    // 批量查询优化
    @Query("SELECT w FROM Wallet w WHERE w.user.id IN :userIds")
    List<Wallet> findByUserIdIn(@Param("userIds") List<Long> userIds);
    
    // 统计查询
    @Query("SELECT SUM(w.balance) FROM Wallet w WHERE w.balance > 0")
    BigDecimal sumTotalBalance();
    
    @Query("SELECT COUNT(w) FROM Wallet w WHERE w.balance > :amount")
    long countWalletsWithBalanceGreaterThan(@Param("amount") BigDecimal amount);
    

    

}