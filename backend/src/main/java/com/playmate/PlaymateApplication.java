package com.playmate;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class PlaymateApplication {

    public static void main(String[] args) {
        System.out.println("=========================================");
        System.out.println("启动陪玩伴侣后端服务");
        System.out.println("端口: 7777");
        System.out.println("访问: http://localhost:7777");
        System.out.println("健康检查: http://localhost:7777/api/health");
        System.out.println("=========================================");
        SpringApplication.run(PlaymateApplication.class, args);
    }
}