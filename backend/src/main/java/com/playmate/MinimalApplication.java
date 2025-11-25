package com.playmate;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class MinimalApplication {
    public static void main(String[] args) {
        SpringApplication.run(MinimalApplication.class, args);
    }

    @GetMapping("/api/health")
    public String health() {
        return "OK";
    }

    @GetMapping("/")
    public String home() {
        return "Backend is running";
    }
}