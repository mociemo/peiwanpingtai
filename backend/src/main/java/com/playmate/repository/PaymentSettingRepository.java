package com.playmate.repository;

import com.playmate.entity.PaymentSetting;
import com.playmate.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface PaymentSettingRepository extends JpaRepository<PaymentSetting, Long> {
    Optional<PaymentSetting> findByUser(User user);
}
