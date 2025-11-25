package com.playmate.controller;

import com.playmate.service.FileUploadService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.Map;

/**
 * 文件上传控制器
 */
@Slf4j
@RestController
@RequestMapping("/api/upload")
@RequiredArgsConstructor
public class FileUploadController {
    
    private final FileUploadService fileUploadService;
    
    /**
     * 上传图片
     */
    @PostMapping("/image")
    public ResponseEntity<Map<String, Object>> uploadImage(
            @RequestParam("file") MultipartFile file) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            String fileUrl = fileUploadService.uploadFile(file, "image");
            response.put("success", true);
            response.put("message", "图片上传成功");
            response.put("data", Map.of(
                "url", fileUrl,
                "type", "image",
                "size", file.getSize(),
                "originalName", file.getOriginalFilename()
            ));
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("图片上传失败", e);
            response.put("success", false);
            response.put("message", "图片上传失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * 上传语音
     */
    @PostMapping("/voice")
    public ResponseEntity<Map<String, Object>> uploadVoice(
            @RequestParam("file") MultipartFile file) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            String fileUrl = fileUploadService.uploadFile(file, "voice");
            response.put("success", true);
            response.put("message", "语音上传成功");
            response.put("data", Map.of(
                "url", fileUrl,
                "type", "voice",
                "size", file.getSize(),
                "originalName", file.getOriginalFilename()
            ));
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("语音上传失败", e);
            response.put("success", false);
            response.put("message", "语音上传失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * 上传视频
     */
    @PostMapping("/video")
    public ResponseEntity<Map<String, Object>> uploadVideo(
            @RequestParam("file") MultipartFile file) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            String fileUrl = fileUploadService.uploadFile(file, "video");
            response.put("success", true);
            response.put("message", "视频上传成功");
            response.put("data", Map.of(
                "url", fileUrl,
                "type", "video",
                "size", file.getSize(),
                "originalName", file.getOriginalFilename()
            ));
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("视频上传失败", e);
            response.put("success", false);
            response.put("message", "视频上传失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * 删除文件
     */
    @DeleteMapping
    public ResponseEntity<Map<String, Object>> deleteFile(
            @RequestParam("url") String fileUrl) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            boolean deleted = fileUploadService.deleteFile(fileUrl);
            response.put("success", deleted);
            response.put("message", deleted ? "文件删除成功" : "文件不存在或删除失败");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("文件删除失败", e);
            response.put("success", false);
            response.put("message", "文件删除失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * 获取文件信息
     */
    @GetMapping("/info")
    public ResponseEntity<Map<String, Object>> getFileInfo(
            @RequestParam("url") String fileUrl) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 这里可以添加获取文件信息的逻辑
            response.put("success", true);
            response.put("message", "获取文件信息成功");
            response.put("data", Map.of(
                "url", fileUrl,
                "exists", true
            ));
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("获取文件信息失败", e);
            response.put("success", false);
            response.put("message", "获取文件信息失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
}