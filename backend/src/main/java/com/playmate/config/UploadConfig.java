package com.playmate.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.lang.NonNull;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * 文件上传配置
 */
@Configuration
public class UploadConfig implements WebMvcConfigurer {
    
    @Value("${app.upload.local.base-path:uploads}")
    private String localBasePath;
    
    @Value("${app.upload.local.base-url:http://localhost:8888/uploads}")
    private String localBaseUrl;
    
    @Override
    public void addResourceHandlers(@NonNull ResourceHandlerRegistry registry) {
        // 配置文件访问路径
        String location = "file:" + localBasePath + "/";
        String path = "/uploads/**";
        
        registry.addResourceHandler(path)
                .addResourceLocations(location)
                .setCachePeriod(3600)
                .resourceChain(true);
    }
}