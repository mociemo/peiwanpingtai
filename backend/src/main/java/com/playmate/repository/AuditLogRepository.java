package com.playmate.repository;

import com.playmate.entity.AuditLog;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 审计日志数据访问层
 */
@Repository
public interface AuditLogRepository extends JpaRepository<AuditLog, Long> {

    /**
     * 根据条件查询审计日志
     */
    @Query("SELECT a FROM AuditLog a WHERE " +
           "(:username IS NULL OR a.username = :username) AND " +
           "(:operation IS NULL OR a.operation = :operation) AND " +
           "(:startTime IS NULL OR a.createTime >= :startTime) AND " +
           "(:endTime IS NULL OR a.createTime <= :endTime) " +
           "ORDER BY a.createTime DESC")
    Page<AuditLog> findByConditions(@Param("username") String username,
                                  @Param("operation") String operation,
                                  @Param("startTime") LocalDateTime startTime,
                                  @Param("endTime") LocalDateTime endTime,
                                  Pageable pageable);

    /**
     * 查询用户最近的操作记录
     */
    @Query("SELECT a FROM AuditLog a WHERE a.username = :username " +
           "ORDER BY a.createTime DESC")
    List<AuditLog> findRecentByUsernameOrderByCreateTimeDesc(@Param("username") String username, Pageable pageable);

    /**
     * 查询安全事件
     */
    @Query("SELECT a FROM AuditLog a WHERE a.operation LIKE CONCAT(:prefix, '%') " +
           "AND a.createTime BETWEEN :startTime AND :endTime " +
           "ORDER BY a.createTime DESC")
    Page<AuditLog> findByOperationStartingWithAndCreateTimeBetween(
            @Param("prefix") String prefix,
            @Param("startTime") LocalDateTime startTime,
            @Param("endTime") LocalDateTime endTime,
            Pageable pageable);

    /**
     * 查询失败的操作
     */
    @Query("SELECT a FROM AuditLog a WHERE a.success = false " +
           "AND a.createTime BETWEEN :startTime AND :endTime " +
           "ORDER BY a.createTime DESC")
    Page<AuditLog> findFailedOperationsByTimeRange(
            @Param("startTime") LocalDateTime startTime,
            @Param("endTime") LocalDateTime endTime,
            Pageable pageable);

    /**
     * 统计用户操作次数
     */
    @Query("SELECT a.operation, COUNT(a) FROM AuditLog a " +
           "WHERE a.username = :username " +
           "AND a.createTime BETWEEN :startTime AND :endTime " +
           "GROUP BY a.operation")
    List<Object[]> countUserOperationsByType(
            @Param("username") String username,
            @Param("startTime") LocalDateTime startTime,
            @Param("endTime") LocalDateTime endTime);

    /**
     * 统计IP访问频率
     */
    @Query("SELECT a.ipAddress, COUNT(a) FROM AuditLog a " +
           "WHERE a.createTime BETWEEN :startTime AND :endTime " +
           "GROUP BY a.ipAddress " +
           "ORDER BY COUNT(a) DESC")
    List<Object[]> countIpAccessFrequency(
            @Param("startTime") LocalDateTime startTime,
            @Param("endTime") LocalDateTime endTime);

    /**
     * 查询支付相关日志
     */
    @Query("SELECT a FROM AuditLog a WHERE a.operation LIKE 'PAYMENT_%' " +
           "AND a.createTime BETWEEN :startTime AND :endTime " +
           "ORDER BY a.createTime DESC")
    Page<AuditLog> findPaymentLogsByTimeRange(
            @Param("startTime") LocalDateTime startTime,
            @Param("endTime") LocalDateTime endTime,
            Pageable pageable);

    /**
     * 删除过期的审计日志
     */
    @Query("DELETE FROM AuditLog a WHERE a.createTime < :expireTime")
    void deleteExpiredLogs(@Param("expireTime") LocalDateTime expireTime);

    /**
     * 根据用户名查询操作记录（按时间倒序）
     */
    @Query("SELECT a FROM AuditLog a WHERE a.username = :username " +
           "ORDER BY a.createTime DESC")
    Page<AuditLog> findByUsernameOrderByCreateTimeDesc(
            @Param("username") String username,
            Pageable pageable);

    /**
     * 根据操作类型和时间范围查询
     */
    @Query("SELECT a FROM AuditLog a WHERE a.operation = :operation " +
           "AND a.createTime BETWEEN :startTime AND :endTime " +
           "ORDER BY a.createTime DESC")
    Page<AuditLog> findByOperationAndCreateTimeBetween(
            @Param("operation") String operation,
            @Param("startTime") LocalDateTime startTime,
            @Param("endTime") LocalDateTime endTime,
            Pageable pageable);

    /**
     * 根据时间范围查询所有记录
     */
    @Query("SELECT a FROM AuditLog a WHERE a.createTime BETWEEN :startTime AND :endTime " +
           "ORDER BY a.createTime DESC")
    Page<AuditLog> findByCreateTimeBetween(
            @Param("startTime") LocalDateTime startTime,
            @Param("endTime") LocalDateTime endTime,
            Pageable pageable);
}