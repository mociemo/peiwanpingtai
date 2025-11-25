package com.playmate.controller;

import com.playmate.dto.ApiResponse;
import com.playmate.entity.User;
import com.playmate.service.UserService;
import com.playmate.service.PostService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 搜索控制器
 */
@RestController
@RequestMapping("/api/search")
@RequiredArgsConstructor
public class SearchController {
    
    private final UserService userService;
    private final PostService postService;
    
    /**
     * 搜索用户
     */
    @GetMapping("/users")
    public ResponseEntity<ApiResponse<Page<User>>> searchUsers(
            @RequestParam String keyword,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String gameType,
            @RequestParam(required = false) String skillLevel,
            @RequestParam(required = false) Double minPrice,
            @RequestParam(required = false) Double maxPrice) {
        
        try {
            Sort sort = Sort.by(Sort.Direction.DESC, "createTime");
            Pageable pageable = PageRequest.of(page, size, sort);
            
            // 这里应该实现具体的搜索逻辑
            // 暂时返回空结果，可以根据需要实现
            Page<User> users = userService.searchUsers(keyword, gameType, skillLevel, minPrice, maxPrice, pageable);
            
            // 隐藏敏感信息
            users.getContent().forEach(user -> user.setPassword(null));
            
            return ResponseEntity.ok(ApiResponse.success(users));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("搜索用户失败: " + e.getMessage()));
        }
    }
    
    /**
     * 搜索动态
     */
    @GetMapping("/posts")
    public ResponseEntity<ApiResponse<Page<?>>> searchPosts(
            @RequestParam String keyword,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String gameType) {
        
        try {
            Sort sort = Sort.by(Sort.Direction.DESC, "createTime");
            Pageable pageable = PageRequest.of(page, size, sort);
            
            // 这里应该实现具体的搜索逻辑
            // 暂时返回空结果，可以根据需要实现
            var posts = postService.searchPosts(keyword, (com.playmate.entity.PostStatus) null, pageable);
            
            return ResponseEntity.ok(ApiResponse.success(posts));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("搜索动态失败: " + e.getMessage()));
        }
    }
    
    /**
     * 通用搜索
     */
    @GetMapping("/all")
    public ResponseEntity<ApiResponse<Map<String, Object>>> searchAll(
            @RequestParam String keyword,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        try {
            Sort sort = Sort.by(Sort.Direction.DESC, "createTime");
            Pageable pageable = PageRequest.of(page, size, sort);
            
            // 搜索用户
            Page<User> users = userService.searchUsers(keyword, null, null, null, null, pageable);
            // 隐藏敏感信息
            users.getContent().forEach(user -> user.setPassword(null));
            
            // 搜索动态
            var posts = postService.searchPosts(keyword, (com.playmate.entity.PostStatus) null, pageable);
            
            Map<String, Object> result = Map.of(
                "users", users,
                "posts", posts
            );
            
            return ResponseEntity.ok(ApiResponse.success("搜索成功", result));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("搜索失败: " + e.getMessage()));
        }
    }
}