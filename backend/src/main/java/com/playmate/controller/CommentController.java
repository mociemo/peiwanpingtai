package com.playmate.controller;

import com.playmate.dto.ApiResponse;
import com.playmate.dto.CommentRequest;
import com.playmate.dto.CommentResponse;
import com.playmate.entity.User;
import com.playmate.service.CommentService;
import com.playmate.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/comments")
@RequiredArgsConstructor
@SuppressWarnings("null")
public class CommentController {
    
    private final CommentService commentService;
    private final UserService userService;
    
    @GetMapping("/post/{postId}")
    public ResponseEntity<ApiResponse<Page<CommentResponse>>> getCommentsByPostId(
            @PathVariable Long postId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.ASC, "createTime"));
        Page<CommentResponse> comments = commentService.getCommentsByPostId(postId, pageable);
        return ResponseEntity.ok(ApiResponse.success(comments));
    }
    
    @GetMapping("/user/{userId}")
    public ResponseEntity<ApiResponse<Page<CommentResponse>>> getCommentsByUserId(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createTime"));
        Page<CommentResponse> comments = commentService.getUserComments(userId, null, pageable);
        return ResponseEntity.ok(ApiResponse.success(comments));
    }
    
    @PostMapping("/post/{postId}")
    public ResponseEntity<ApiResponse<CommentResponse>> createComment(
            Authentication authentication,
            @PathVariable Long postId,
            @RequestBody CommentRequest request) {
        try {
            Long userId = getUserIdFromUsername(authentication.getName());
            CommentResponse comment = commentService.createComment(userId, postId, request);
            return ResponseEntity.ok(ApiResponse.success(comment));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("创建评论失败: " + e.getMessage()));
        }
    }
    
    @PutMapping("/{commentId}")
    public ResponseEntity<ApiResponse<CommentResponse>> updateComment(
            @PathVariable Long commentId,
            Authentication authentication,
            @RequestBody CommentRequest request) {
        try {
            Long userId = getUserIdFromUsername(authentication.getName());
            CommentResponse comment = commentService.updateComment(commentId, userId, request);
            return ResponseEntity.ok(ApiResponse.success(comment));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("更新评论失败: " + e.getMessage()));
        }
    }
    
    @DeleteMapping("/{commentId}")
    public ResponseEntity<ApiResponse<Void>> deleteComment(
            @PathVariable Long commentId,
            Authentication authentication) {
        try {
            Long userId = getUserIdFromUsername(authentication.getName());
            commentService.deleteComment(commentId, userId);
            return ResponseEntity.ok(ApiResponse.success(null));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("删除评论失败: " + e.getMessage()));
        }
    }
    
    @PostMapping("/{commentId}/like")
    public ResponseEntity<ApiResponse<Void>> likeComment(
            @PathVariable Long commentId,
            Authentication authentication) {
        try {
            Long userId = getUserIdFromUsername(authentication.getName());
            commentService.likeComment(commentId, userId);
            return ResponseEntity.ok(ApiResponse.success(null));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("点赞失败: " + e.getMessage()));
        }
    }
    
    @PostMapping("/{commentId}/unlike")
    public ResponseEntity<ApiResponse<Void>> unlikeComment(
            @PathVariable Long commentId,
            Authentication authentication) {
        try {
            Long userId = getUserIdFromUsername(authentication.getName());
            commentService.unlikeComment(commentId, userId);
            return ResponseEntity.ok(ApiResponse.success(null));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("取消点赞失败: " + e.getMessage()));
        }
    }
    
    private Long getUserIdFromUsername(String username) {
        User user = userService.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        return user.getId();
    }
    
    @GetMapping("/{commentId}")
    public ResponseEntity<ApiResponse<CommentResponse>> getCommentById(@PathVariable Long commentId) {
        CommentResponse comment = commentService.getCommentById(commentId);
        return ResponseEntity.ok(ApiResponse.success(comment));
    }
}