package com.playmate.service;

import com.playmate.entity.Payment;
import com.playmate.entity.Wallet;
import com.playmate.entity.User;
import com.playmate.repository.PaymentRepository;
import com.playmate.repository.UserRepository;
import com.playmate.repository.WalletRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.lang.NonNull;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Service
@RequiredArgsConstructor
public class WalletService {
    
    private final WalletRepository walletRepository;
    private final UserRepository userRepository;
    private final PaymentRepository paymentRepository;
    
    public Wallet getUserWallet(@NonNull Long userId) {
        return walletRepository.findByUserId(userId)
            .orElseGet(() -> createWalletForUser(userId));
    }
    
    @Transactional
    public Wallet createWalletForUser(@NonNull Long userId) {
        if (walletRepository.existsByUserId(userId)) {
            throw new RuntimeException("用户钱包已存在");
        }
        
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("用户不存在"));
            
        Wallet wallet = new Wallet();
        wallet.setUser(user);
        wallet.setBalance(BigDecimal.ZERO);
        wallet.setFrozenBalance(BigDecimal.ZERO);
        wallet.setTotalRecharge(BigDecimal.ZERO);
        wallet.setTotalWithdraw(BigDecimal.ZERO);
        wallet.setTotalIncome(BigDecimal.ZERO);
        
        return walletRepository.save(wallet);
    }
    
    @Transactional
    public Wallet rechargeWallet(@NonNull Long userId, @NonNull BigDecimal amount, @NonNull Payment.PaymentMethod paymentMethod) {
        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new RuntimeException("充值金额必须大于0");
        }
        
        Wallet wallet = getUserWallet(userId);
        
        // 创建充值支付记录
        Payment payment = new Payment();
        payment.setUser(userRepository.findById(userId).orElseThrow());
        payment.setAmount(amount);
        payment.setPaymentMethod(paymentMethod);
        payment.setPaymentType(Payment.PaymentType.RECHARGE);
        payment.setStatus(Payment.PaymentStatus.PENDING);
        payment.setPaymentNo("RECHARGE_" + System.currentTimeMillis());
        
        paymentRepository.save(payment);
        
        // 注意：此方法仅创建充值订单，不直接更新钱包余额
        // 钱包余额更新应在PaymentService.processPayment()中处理
        // 这里返回钱包当前状态
        return wallet;
    }
    
    @Transactional
    public Wallet withdrawFromWallet(Long userId, BigDecimal amount) {
        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new RuntimeException("提现金额必须大于0");
        }
        
        Wallet wallet = walletRepository.findByUserIdWithLock(userId)
            .orElseThrow(() -> new RuntimeException("用户钱包不存在"));
            
        if (wallet.getBalance().compareTo(amount) < 0) {
            throw new RuntimeException("余额不足");
        }
        
        wallet.setBalance(wallet.getBalance().subtract(amount));
        wallet.setTotalWithdraw(wallet.getTotalWithdraw().add(amount));
        
        // 创建提现记录
        Payment withdrawPayment = new Payment();
        withdrawPayment.setUser(wallet.getUser());
        withdrawPayment.setAmount(amount);
        withdrawPayment.setPaymentType(Payment.PaymentType.WITHDRAW);
        withdrawPayment.setStatus(Payment.PaymentStatus.PENDING);
        withdrawPayment.setPaymentNo("WITHDRAW_" + System.currentTimeMillis());
        
        paymentRepository.save(withdrawPayment);
        
        return walletRepository.save(wallet);
    }
    
    @Transactional
    public void freezeBalance(Long userId, BigDecimal amount) {
        Wallet wallet = walletRepository.findByUserIdWithLock(userId)
            .orElseThrow(() -> new RuntimeException("用户钱包不存在"));
            
        if (wallet.getBalance().compareTo(amount) < 0) {
            throw new RuntimeException("余额不足");
        }
        
        wallet.setBalance(wallet.getBalance().subtract(amount));
        wallet.setFrozenBalance(wallet.getFrozenBalance().add(amount));
        
        walletRepository.save(wallet);
    }
    
    @Transactional
    public void unfreezeBalance(Long userId, BigDecimal amount) {
        Wallet wallet = walletRepository.findByUserIdWithLock(userId)
            .orElseThrow(() -> new RuntimeException("用户钱包不存在"));
            
        if (wallet.getFrozenBalance().compareTo(amount) < 0) {
            throw new RuntimeException("冻结余额不足");
        }
        
        wallet.setFrozenBalance(wallet.getFrozenBalance().subtract(amount));
        wallet.setBalance(wallet.getBalance().add(amount));
        
        walletRepository.save(wallet);
    }
    
    @Transactional
    public void deductFromFrozenBalance(Long userId, BigDecimal amount) {
        Wallet wallet = walletRepository.findByUserIdWithLock(userId)
            .orElseThrow(() -> new RuntimeException("用户钱包不存在"));
            
        if (wallet.getFrozenBalance().compareTo(amount) < 0) {
            throw new RuntimeException("冻结余额不足");
        }
        
        wallet.setFrozenBalance(wallet.getFrozenBalance().subtract(amount));
        wallet.setTotalIncome(wallet.getTotalIncome().add(amount));
        
        walletRepository.save(wallet);
    }
    
    @Transactional
    public Wallet addToBalance(Long userId, BigDecimal amount) {
        Wallet wallet = walletRepository.findByUserIdWithLock(userId)
            .orElseThrow(() -> new RuntimeException("用户钱包不存在"));
            
        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new RuntimeException("增加金额必须大于0");
        }
        
        wallet.setBalance(wallet.getBalance().add(amount));
        wallet.setTotalIncome(wallet.getTotalIncome().add(amount));
        
        return walletRepository.save(wallet);
    }
    
    public BigDecimal getAvailableBalance(@NonNull Long userId) {
        Wallet wallet = getUserWallet(userId);
        return wallet.getBalance();
    }
    
    public BigDecimal getFrozenBalance(@NonNull Long userId) {
        Wallet wallet = getUserWallet(userId);
        return wallet.getFrozenBalance();
    }
    
    public BigDecimal getTotalBalance(@NonNull Long userId) {
        Wallet wallet = getUserWallet(userId);
        return wallet.getBalance().add(wallet.getFrozenBalance());
    }
}