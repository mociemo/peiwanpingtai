package com.playmate.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 审计日志实体
 */
@Entity
@Table(name = "audit_logs")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class AuditLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * 操作用户名
     */
    @Column(name = "username", length = 50)
    private String username;

    /**
     * 操作类型
     */
    @Column(name = "operation", length = 50)
    private String operation;

    /**
     * 资源类型
     */
    @Column(name = "resource_type", length = 50)
    private String resourceType;

    /**
     * 资源ID
     */
    @Column(name = "resource_id", length = 100)
    private String resourceId;

    /**
     * 资源名称
     */
    @Column(name = "resource", length = 200)
    private String resource;

    /**
     * 操作详情
     */
    @Column(name = "details", columnDefinition = "TEXT")
    private String details;

    /**
     * IP地址
     */
    @Column(name = "ip_address", length = 45)
    private String ipAddress;

    /**
     * 用户代理
     */
    @Column(name = "user_agent", length = 500)
    private String userAgent;

    /**
     * 请求URI
     */
    @Column(name = "request_uri", length = 500)
    private String requestUri;

    /**
     * HTTP方法
     */
    @Column(name = "http_method", length = 10)
    private String httpMethod;

    /**
     * 操作金额（支付相关）
     */
    @Column(name = "amount", precision = 19, scale = 2)
    private BigDecimal amount;

    /**
     * 操作是否成功
     */
    @Column(name = "success")
    private Boolean success;

    /**
     * 失败原因
     */
    @Column(name = "failure_reason", length = 500)
    private String failureReason;

    /**
     * 创建时间
     */
    @CreatedDate
    @Column(name = "create_time", nullable = false, updatable = false)
    private LocalDateTime createTime;

    /**
     * 修改时间
     */
    @LastModifiedDate
    @Column(name = "update_time")
    private LocalDateTime updateTime;

    /**
     * 创建者
     */
    @Column(name = "created_by", length = 50)
    private String createdBy;

    /**
     * 修改者
     */
    @Column(name = "updated_by", length = 50)
    private String updatedBy;
}