package com.playmate.repository;

import com.playmate.entity.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, Long> {
    
    Optional<Payment> findByPaymentNo(String paymentNo);
    
    List<Payment> findByUserIdOrderByCreatedAtDesc(Long userId);
    
    List<Payment> findByUserIdAndStatusOrderByCreatedAtDesc(Long userId, Payment.PaymentStatus status);
    
    List<Payment> findByOrderId(Long orderId);
    
    @Query("SELECT COALESCE(SUM(p.amount), 0) FROM Payment p WHERE p.user.id = :userId AND p.status = 'SUCCESS' AND p.paymentType = 'RECHARGE'")
    BigDecimal sumSuccessfulRechargesByUserId(@Param("userId") Long userId);
    
    @Query("SELECT COALESCE(SUM(p.amount), 0) FROM Payment p WHERE p.user.id = :userId AND p.status = 'SUCCESS' AND p.paymentType = 'ORDER'")
    BigDecimal sumSuccessfulOrderPaymentsByUserId(@Param("userId") Long userId);
    
    @Query("SELECT COUNT(p) FROM Payment p WHERE p.user.id = :userId AND p.status = 'SUCCESS'")
    Long countSuccessfulPaymentsByUserId(@Param("userId") Long userId);
    
    List<Payment> findByStatusAndCreatedAtBefore(Payment.PaymentStatus status, LocalDateTime dateTime);
}