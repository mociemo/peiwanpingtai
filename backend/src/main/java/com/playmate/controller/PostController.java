package com.playmate.controller;

import com.playmate.dto.ApiResponse;
import com.playmate.dto.CreatePostRequest;
import com.playmate.dto.PostResponse;
import com.playmate.entity.PostStatus;
import com.playmate.entity.PostType;
import com.playmate.entity.User;
import com.playmate.service.PostService;
import com.playmate.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;

import java.util.List;

@RestController
@RequestMapping("/api/posts")
@RequiredArgsConstructor
public class PostController {
    
    private final PostService postService;
    private final UserService userService;
    
    @GetMapping
    public ResponseEntity<ApiResponse<Page<PostResponse>>> getPosts(
            @RequestParam(defaultValue = "PUBLISHED") PostStatus status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "createTime") String sort,
            @RequestParam(defaultValue = "desc") String direction) {
        
        Sort.Direction sortDirection = direction.equalsIgnoreCase("asc") ? Sort.Direction.ASC : Sort.Direction.DESC;
        Pageable pageable = PageRequest.of(page, size, Sort.by(sortDirection, sort));
        
        Page<PostResponse> posts = postService.getPosts(status, pageable);
        return ResponseEntity.ok(ApiResponse.success(posts));
    }
    
    @GetMapping("/user/{userId}")
    public ResponseEntity<ApiResponse<Page<PostResponse>>> getUserPosts(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "PUBLISHED") PostStatus status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createTime"));
        Page<PostResponse> posts = postService.getUserPosts(userId, status, pageable);
        return ResponseEntity.ok(ApiResponse.success(posts));
    }
    
    @GetMapping("/type/{type}")
    public ResponseEntity<ApiResponse<Page<PostResponse>>> getPostsByType(
            @PathVariable PostType type,
            @RequestParam(defaultValue = "PUBLISHED") PostStatus status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createTime"));
        Page<PostResponse> posts = postService.getPostsByType(type, status, pageable);
        return ResponseEntity.ok(ApiResponse.success(posts));
    }
    
    @GetMapping("/game/{gameName}")
    public ResponseEntity<ApiResponse<Page<PostResponse>>> getPostsByGame(
            @PathVariable String gameName,
            @RequestParam(defaultValue = "PUBLISHED") PostStatus status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createTime"));
        Page<PostResponse> posts = postService.getPostsByGame(gameName, status, pageable);
        return ResponseEntity.ok(ApiResponse.success(posts));
    }
    
    @GetMapping("/search")
    public ResponseEntity<ApiResponse<Page<PostResponse>>> searchPosts(
            @RequestParam String keyword,
            @RequestParam(defaultValue = "PUBLISHED") PostStatus status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createTime"));
        Page<PostResponse> posts = postService.searchPosts(keyword, status, pageable);
        return ResponseEntity.ok(ApiResponse.success(posts));
    }
    
    @GetMapping("/following")
    public ResponseEntity<ApiResponse<Page<PostResponse>>> getFollowingPosts(
            @RequestParam List<Long> userIds,
            @RequestParam(defaultValue = "PUBLISHED") PostStatus status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createTime"));
        Page<PostResponse> posts = postService.getPostsByUserIds(userIds, status, pageable);
        return ResponseEntity.ok(ApiResponse.success(posts));
    }
    
    @PostMapping
    public ResponseEntity<ApiResponse<PostResponse>> createPost(
            Authentication authentication,
            @Valid @RequestBody CreatePostRequest request) {
        try {
            // 验证请求数据
            if (request.getContent() == null || request.getContent().trim().isEmpty()) {
                return ResponseEntity.badRequest().body(ApiResponse.error("动态内容不能为空"));
            }
            
            String username = authentication.getName();
            if (username == null) {
                return ResponseEntity.status(401).body(ApiResponse.error("用户未认证"));
            }
            
            Long userId = getUserIdFromUsername(username);
            if (userId == null) {
                return ResponseEntity.badRequest().body(ApiResponse.error("用户不存在"));
            }
            
            PostResponse post = postService.createPost(userId, request);
            return ResponseEntity.ok(ApiResponse.success(post));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("创建帖子失败: " + e.getMessage()));
        }
    }
    
    @PutMapping("/{postId}")
    public ResponseEntity<ApiResponse<PostResponse>> updatePost(
            @PathVariable Long postId,
            Authentication authentication,
            @RequestBody CreatePostRequest request) {
        try {
            String username = authentication.getName();
            Long userId = getUserIdFromUsername(username);
            PostResponse post = postService.updatePost(postId, userId, request);
            return ResponseEntity.ok(ApiResponse.success(post));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("更新帖子失败: " + e.getMessage()));
        }
    }
    
    @DeleteMapping("/{postId}")
    public ResponseEntity<ApiResponse<Void>> deletePost(
            @PathVariable Long postId,
            Authentication authentication) {
        try {
            String username = authentication.getName();
            Long userId = getUserIdFromUsername(username);
            postService.deletePost(postId, userId);
            return ResponseEntity.ok(ApiResponse.success(null));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("删除帖子失败: " + e.getMessage()));
        }
    }
    
    @PostMapping("/{postId}/like")
    public ResponseEntity<ApiResponse<Void>> likePost(
            @PathVariable Long postId,
            Authentication authentication) {
        try {
            String username = authentication.getName();
            Long userId = getUserIdFromUsername(username);
            postService.likePost(postId, userId);
            return ResponseEntity.ok(ApiResponse.success(null));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("点赞失败: " + e.getMessage()));
        }
    }
    
    @PostMapping("/{postId}/unlike")
    public ResponseEntity<ApiResponse<Void>> unlikePost(
            @PathVariable Long postId,
            Authentication authentication) {
        try {
            String username = authentication.getName();
            Long userId = getUserIdFromUsername(username);
            postService.unlikePost(postId, userId);
            return ResponseEntity.ok(ApiResponse.success(null));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("取消点赞失败: " + e.getMessage()));
        }
    }
    
    private Long getUserIdFromUsername(String username) {
        User user = userService.findByUsername(username);
        return user.getId();
    }
    
    @GetMapping("/{postId}")
    public ResponseEntity<ApiResponse<PostResponse>> getPostById(@PathVariable Long postId) {
        PostResponse post = postService.getPostById(postId);
        return ResponseEntity.ok(ApiResponse.success(post));
    }
}