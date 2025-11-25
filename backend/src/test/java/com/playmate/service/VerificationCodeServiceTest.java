package com.playmate.service;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(classes = com.playmate.PlaymateApplication.class)
public class VerificationCodeServiceTest {

    @Autowired
    private VerificationCodeService verificationCodeService;

    @Test
    public void testGenerateAndVerifyCode_InMemoryFallback() {
        String phone = "13800000000";

        // Ensure we can send
        assertTrue(verificationCodeService.canSendCode(phone));

        String code = verificationCodeService.generateCode();
        assertNotNull(code);
        assertEquals(6, code.length());

        verificationCodeService.storeCode(phone, code);

        // Cannot resend immediately
        assertFalse(verificationCodeService.canSendCode(phone));

        // Wrong code
        assertFalse(verificationCodeService.verifyCode(phone, "000000"));

        // Correct code
        assertTrue(verificationCodeService.verifyCode(phone, code));

        // After successful verify, can send again
        assertTrue(verificationCodeService.canSendCode(phone));
    }
}
