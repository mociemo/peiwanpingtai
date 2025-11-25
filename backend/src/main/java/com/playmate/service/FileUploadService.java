package com.playmate.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import net.coobird.thumbnailator.Thumbnails;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.UUID;

/**
 * 文件上传服务
 * 支持本地存储和OSS云存储
 */
@Slf4j
@Service
public class FileUploadService {
    
    @Value("${app.upload.storage-type:local}")
    private String storageType;
    
    @Value("${app.upload.local.base-path:uploads}")
    private String localBasePath;
    
    @Value("${app.upload.local.base-url:http://localhost:8888/uploads}")
    private String localBaseUrl;
    
    @Value("${app.upload.oss.endpoint:}")
    private String ossEndpoint;
    
    @Value("${app.upload.oss.access-key-id:}")
    private String ossAccessKeyId;
    
    @Value("${app.upload.oss.access-key-secret:}")
    private String ossAccessKeySecret;
    
    @Value("${app.upload.oss.bucket-name:}")
    private String ossBucketName;
    
    @Value("${app.upload.oss.domain:}")
    private String ossDomain;
    
    // 支持的文件类型
    private static final String[] IMAGE_TYPES = {"jpg", "jpeg", "png", "gif", "webp"};
    private static final String[] VOICE_TYPES = {"mp3", "wav", "amr", "aac"};
    private static final String[] VIDEO_TYPES = {"mp4", "avi", "mov", "wmv"};
    private static final long MAX_FILE_SIZE = 50 * 1024 * 1024; // 50MB
    
    /**
     * 上传文件
     */
    public String uploadFile(MultipartFile file, String type) throws IOException {
        // 验证文件
        validateFile(file, type);
        
        String fileName = generateFileName(file);
        String relativePath = type + "/" + getDateString() + "/" + fileName;
        
        if ("oss".equals(storageType) && isOssConfigured()) {
            return uploadToOSS(file, relativePath);
        } else {
            return uploadToLocal(file, relativePath);
        }
    }
    
    /**
     * 本地存储
     */
    private String uploadToLocal(MultipartFile file, String relativePath) throws IOException {
        try {
            Path uploadPath = Paths.get(localBasePath, relativePath).getParent();
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }
            
            Path filePath = Paths.get(localBasePath, relativePath);
            Files.copy(file.getInputStream(), filePath);
            
            // 如果是图片，生成缩略图
            if (isImageFile(file.getOriginalFilename())) {
                generateThumbnail(filePath.toString());
            }
            
            String fileUrl = localBaseUrl + "/" + relativePath;
            log.info("文件上传成功: {}", fileUrl);
            return fileUrl;
            
        } catch (IOException e) {
            log.error("文件上传失败", e);
            throw new IOException("文件上传失败: " + e.getMessage());
        }
    }
    
    /**
     * OSS云存储
     */
    private String uploadToOSS(MultipartFile file, String relativePath) throws IOException {
        try {
            // 检查OSS配置
            if (!isOssConfigured()) {
                log.warn("OSS配置不完整，回退到本地存储");
                return uploadToLocal(file, relativePath);
            }
            
            // 这里应该集成阿里云OSS SDK
            // 示例代码（需要添加依赖）：
            /*
            OSS ossClient = new OSSClientBuilder().build(
                ossEndpoint, 
                ossAccessKeyId, 
                ossAccessKeySecret
            );
            
            try {
                PutObjectRequest putObjectRequest = new PutObjectRequest(
                    ossBucketName, 
                    relativePath, 
                    file.getInputStream()
                );
                
                ObjectMetadata metadata = new ObjectMetadata();
                metadata.setContentLength(file.getSize());
                metadata.setContentType(file.getContentType());
                putObjectRequest.setMetadata(metadata);
                
                ossClient.putObject(putObjectRequest);
                
                // 生成访问URL
                String fileUrl = ossDomain != null && !ossDomain.isEmpty() 
                    ? ossDomain + "/" + relativePath
                    : "https://" + ossBucketName + "." + ossEndpoint.replace("https://", "") + "/" + relativePath;
                    
                log.info("OSS上传成功: {}", fileUrl);
                return fileUrl;
                
            } finally {
                ossClient.shutdown();
            }
            */
            
            // 暂时回退到本地存储
            log.info("OSS上传功能暂未完全实现，使用本地存储，文件: {}", relativePath);
            return uploadToLocal(file, relativePath);
            
        } catch (Exception e) {
            log.error("OSS上传失败，回退到本地存储: {}", e.getMessage());
            return uploadToLocal(file, relativePath);
        }
    }
    
    /**
     * 验证文件
     */
    private void validateFile(MultipartFile file, String type) throws IOException {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("文件不能为空");
        }
        
        if (file.getSize() > MAX_FILE_SIZE) {
            throw new IllegalArgumentException("文件大小不能超过50MB");
        }
        
        String originalFilename = file.getOriginalFilename();
        if (originalFilename == null) {
            throw new IllegalArgumentException("文件名不能为空");
        }
        
        String extension = getFileExtension(originalFilename).toLowerCase();
        
        switch (type) {
            case "image":
                if (!isImageFile(originalFilename)) {
                    throw new IllegalArgumentException("不支持的图片格式");
                }
                break;
            case "voice":
                if (!Arrays.asList(VOICE_TYPES).contains(extension)) {
                    throw new IllegalArgumentException("不支持的音频格式");
                }
                break;
            case "video":
                if (!Arrays.asList(VIDEO_TYPES).contains(extension)) {
                    throw new IllegalArgumentException("不支持的视频格式");
                }
                break;
            default:
                throw new IllegalArgumentException("不支持的文件类型: " + type);
        }
    }
    
    /**
     * 生成文件名
     */
    private String generateFileName(MultipartFile file) {
        String originalFilename = file.getOriginalFilename();
        String extension = getFileExtension(originalFilename);
        return UUID.randomUUID().toString() + "." + extension;
    }
    
    /**
     * 获取文件扩展名
     */
    private String getFileExtension(String filename) {
        return filename.substring(filename.lastIndexOf(".") + 1);
    }
    
    /**
     * 判断是否为图片文件
     */
    private boolean isImageFile(String filename) {
        String extension = getFileExtension(filename).toLowerCase();
        return Arrays.asList(IMAGE_TYPES).contains(extension);
    }
    
    /**
     * 生成缩略图
     */
    private void generateThumbnail(String originalPath) {
        try {
            String thumbnailPath = originalPath.replace(".", "_thumb.");
            Thumbnails.of(originalPath)
                    .size(200, 200)
                    .keepAspectRatio(true)
                    .toFile(thumbnailPath);
            log.info("缩略图生成成功: {}", thumbnailPath);
        } catch (IOException e) {
            log.warn("缩略图生成失败: {}", e.getMessage());
        }
    }
    
    /**
     * 获取日期字符串
     */
    private String getDateString() {
        return java.time.LocalDate.now().toString().replace("-", "");
    }
    
    /**
     * 检查OSS是否配置
     */
    private boolean isOssConfigured() {
        return ossEndpoint != null && !ossEndpoint.isEmpty() &&
               ossAccessKeyId != null && !ossAccessKeyId.isEmpty() &&
               ossAccessKeySecret != null && !ossAccessKeySecret.isEmpty() &&
               ossBucketName != null && !ossBucketName.isEmpty();
    }
    
    /**
     * 删除文件
     */
    public boolean deleteFile(String fileUrl) {
        try {
            if (fileUrl.startsWith(localBaseUrl)) {
                String relativePath = fileUrl.substring(localBaseUrl.length() + 1);
                Path filePath = Paths.get(localBasePath, relativePath);
                if (Files.exists(filePath)) {
                    Files.delete(filePath);
                    
                    // 删除缩略图
                    String thumbnailPath = filePath.toString().replace(".", "_thumb.");
                    Path thumbnailFile = Paths.get(thumbnailPath);
                    if (Files.exists(thumbnailFile)) {
                        Files.delete(thumbnailFile);
                    }
                    
                    log.info("文件删除成功: {}", fileUrl);
                    return true;
                }
            }
            return false;
        } catch (IOException e) {
            log.error("文件删除失败: {}", fileUrl, e);
            return false;
        }
    }
}