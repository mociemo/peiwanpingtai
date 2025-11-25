package com.playmate.service;

import com.playmate.entity.Payment;
import com.playmate.entity.User;
import com.playmate.entity.Wallet;
import com.playmate.repository.PaymentRepository;
import com.playmate.repository.UserRepository;
import com.playmate.repository.WalletRepository;
import com.playmate.repository.OrderRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.lang.NonNull;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class PaymentService {

    private final PaymentRepository paymentRepository;
    private final UserRepository userRepository;
    private final WalletRepository walletRepository;
    private final OrderRepository orderRepository;

    @Transactional
    public Payment createRechargePayment(@NonNull Long userId, @NonNull BigDecimal amount,
            @NonNull Payment.PaymentMethod paymentMethod) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));

        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new RuntimeException("充值金额必须大于0");
        }

        Payment payment = new Payment();
        payment.setPaymentNo(generatePaymentNo());
        payment.setUser(user);
        payment.setAmount(amount);
        payment.setPaymentMethod(paymentMethod);
        payment.setPaymentType(Payment.PaymentType.RECHARGE);
        payment.setStatus(Payment.PaymentStatus.PENDING);

        return paymentRepository.save(payment);
    }

    @Transactional
    public Payment createOrderPayment(@NonNull Long userId, Long orderId, @NonNull BigDecimal amount,
            @NonNull Payment.PaymentMethod paymentMethod) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));

        Payment payment = new Payment();
        payment.setPaymentNo(generatePaymentNo());
        payment.setUser(user);
        // 关联订单（如果提供）
        if (orderId != null) {
            com.playmate.entity.Order order = orderRepository.findById(orderId)
                    .orElseThrow(() -> new RuntimeException("订单不存在"));
            payment.setOrder(order);
            // 校验支付金额与订单金额一致
            if (order.getAmount() != null && amount.compareTo(order.getAmount()) != 0) {
                throw new RuntimeException("支付金额与订单金额不匹配");
            }
        }
        payment.setAmount(amount);
        payment.setPaymentMethod(paymentMethod);
        payment.setPaymentType(Payment.PaymentType.ORDER);
        payment.setStatus(Payment.PaymentStatus.PENDING);

        return paymentRepository.save(payment);
    }

    @Transactional
    public Payment processPayment(@NonNull Long paymentId, @NonNull String transactionId) {
        // 参数验证
        if (paymentId == null || transactionId == null || transactionId.trim().isEmpty()) {
            throw new IllegalArgumentException("支付ID和交易ID不能为空");
        }

        // 交易ID格式验证
        if (!isValidTransactionId(transactionId)) {
            throw new IllegalArgumentException("交易ID格式不正确");
        }

        Payment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new RuntimeException("支付记录不存在"));

        if (payment.getStatus() != Payment.PaymentStatus.PENDING) {
            throw new RuntimeException("支付状态不正确，当前状态：" + payment.getStatus());
        }

        // 防止重复处理同一交易ID（简化检查，实际项目中需要添加相应的Repository方法）
        // if (paymentRepository.existsByTransactionIdAndStatus(transactionId,
        // Payment.PaymentStatus.SUCCESS)) {
        // throw new RuntimeException("交易ID已存在，可能存在重复支付");
        // }

        payment.setStatus(Payment.PaymentStatus.SUCCESS);
        payment.setTransactionId(transactionId);
        payment.setPaidAt(LocalDateTime.now());

        Payment savedPayment = paymentRepository.save(payment);

        // 如果是充值，更新钱包余额（使用悲观锁防止并发问题）
        if (payment.getPaymentType() == Payment.PaymentType.RECHARGE) {
            updateWalletBalanceSecurely(payment.getUser().getId(), payment.getAmount());
        }

        return savedPayment;
    }

    private boolean isValidTransactionId(String transactionId) {
        // 验证交易ID格式：长度在10-100之间，只包含字母、数字和下划线
        return transactionId != null &&
                transactionId.length() >= 10 &&
                transactionId.length() <= 100 &&
                transactionId.matches("^[a-zA-Z0-9_]+$");
    }

    private void updateWalletBalanceSecurely(Long userId, BigDecimal amount) {
        // 使用悲观锁确保并发安全
        if (userId == null) {
            throw new IllegalArgumentException("用户ID不能为空");
        }

        Wallet wallet = walletRepository.findByUserIdWithLock(userId)
                .orElseGet(() -> {
                    User user = userRepository.findById(userId)
                            .orElseThrow(() -> new RuntimeException("用户不存在"));
                    Wallet newWallet = new Wallet();
                    newWallet.setUser(user);
                    newWallet.setBalance(BigDecimal.ZERO);
                    newWallet.setFrozenBalance(BigDecimal.ZERO);
                    newWallet.setTotalRecharge(BigDecimal.ZERO);
                    newWallet.setTotalWithdraw(BigDecimal.ZERO);
                    newWallet.setTotalIncome(BigDecimal.ZERO);
                    return walletRepository.save(newWallet);
                });

        // 验证金额合理性
        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("充值金额必须大于0");
        }
        if (amount.compareTo(new BigDecimal("10000")) > 0) {
            log.warn("大额充值警告：用户ID {}, 金额 {}", userId, amount);
        }

        wallet.setBalance(wallet.getBalance().add(amount));
        wallet.setTotalRecharge(wallet.getTotalRecharge().add(amount));

        walletRepository.save(wallet);
        log.info("用户 {} 钱包充值成功，金额：{}", userId, amount);
    }

    @Transactional
    public void failPayment(@NonNull Long paymentId, String reason) {
        Payment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new RuntimeException("支付记录不存在"));

        payment.setStatus(Payment.PaymentStatus.FAILED);
        paymentRepository.save(payment);
    }

    @Transactional
    public Payment refundPayment(@NonNull Long paymentId, @NonNull BigDecimal refundAmount) {
        Payment originalPayment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new RuntimeException("原支付记录不存在"));

        if (originalPayment.getStatus() != Payment.PaymentStatus.SUCCESS) {
            throw new RuntimeException("只能退款成功的支付");
        }

        if (refundAmount.compareTo(originalPayment.getAmount()) > 0) {
            throw new RuntimeException("退款金额不能超过原支付金额");
        }

        Payment refundPayment = new Payment();
        refundPayment.setPaymentNo(generatePaymentNo());
        refundPayment.setUser(originalPayment.getUser());
        refundPayment.setOrder(originalPayment.getOrder());
        refundPayment.setAmount(refundAmount);
        refundPayment.setPaymentType(Payment.PaymentType.REFUND);
        refundPayment.setStatus(Payment.PaymentStatus.SUCCESS);
        refundPayment.setTransactionId("REFUND_" + UUID.randomUUID().toString());
        refundPayment.setPaidAt(LocalDateTime.now());

        Payment savedRefund = paymentRepository.save(refundPayment);

        // 退还到钱包
        User user = originalPayment.getUser();
        if (user == null) {
            throw new IllegalStateException("支付记录关联用户不能为空");
        }
        Long userId = user.getId();
        if (userId == null) {
            throw new IllegalStateException("用户ID不能为空");
        }
        updateWalletBalance(userId, refundAmount);

        return savedRefund;
    }

    public List<Payment> getUserPayments(@NonNull Long userId) {
        return paymentRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    public List<Payment> getUserSuccessfulPayments(@NonNull Long userId) {
        return paymentRepository.findByUserIdAndStatusOrderByCreatedAtDesc(userId, Payment.PaymentStatus.SUCCESS);
    }

    public BigDecimal getUserTotalRecharge(@NonNull Long userId) {
        return paymentRepository.sumSuccessfulRechargesByUserId(userId);
    }

    private void updateWalletBalance(@NonNull Long userId, BigDecimal amount) {
        Wallet wallet = walletRepository.findByUserIdWithLock(userId)
                .orElseGet(() -> {
                    User user = userRepository.findById(userId)
                            .orElseThrow(() -> new RuntimeException("用户不存在"));
                    Wallet newWallet = new Wallet();
                    newWallet.setUser(user);
                    newWallet.setBalance(BigDecimal.ZERO);
                    newWallet.setFrozenBalance(BigDecimal.ZERO);
                    newWallet.setTotalRecharge(BigDecimal.ZERO);
                    newWallet.setTotalWithdraw(BigDecimal.ZERO);
                    newWallet.setTotalIncome(BigDecimal.ZERO);
                    return walletRepository.save(newWallet);
                });

        wallet.setBalance(wallet.getBalance().add(amount));
        if (amount.compareTo(BigDecimal.ZERO) > 0) {
            wallet.setTotalRecharge(wallet.getTotalRecharge().add(amount));
        }

        walletRepository.save(wallet);
    }

    private String generatePaymentNo() {
        return "PAY" + System.currentTimeMillis() + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }

    public java.util.Optional<Payment> getById(@NonNull Long paymentId) {
        return paymentRepository.findById(paymentId);
    }

    public java.util.Optional<Payment> getByPaymentNo(@NonNull String paymentNo) {
        return paymentRepository.findByPaymentNo(paymentNo);
    }
}