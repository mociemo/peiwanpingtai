package com.playmate.controller;

import com.playmate.dto.ApiResponse;
import com.playmate.dto.CommentRequest;
import com.playmate.dto.CommentResponse;
import com.playmate.service.CommentService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/comments")
@RequiredArgsConstructor
public class CommentController {
    
    private final CommentService commentService;
    
    @GetMapping("/post/{postId}")
    public ResponseEntity<ApiResponse<Page<CommentResponse>>> getCommentsByPostId(
            @PathVariable String postId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.ASC, "createTime"));
        Page<CommentResponse> comments = commentService.getCommentsByPostId(postId, pageable);
        return ResponseEntity.ok(ApiResponse.success(comments));
    }
    
    @GetMapping("/user/{userId}")
    public ResponseEntity<ApiResponse<Page<CommentResponse>>> getCommentsByUserId(
            @PathVariable String userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createTime"));
        Page<CommentResponse> comments = commentService.getUserComments(userId, null, pageable);
        return ResponseEntity.ok(ApiResponse.success(comments));
    }
    
    @PostMapping("/post/{postId}")
    public ResponseEntity<ApiResponse<CommentResponse>> createComment(
            @RequestHeader("X-User-Id") String userId,
            @PathVariable String postId,
            @RequestBody CommentRequest request) {
        
        CommentResponse comment = commentService.createComment(userId, postId, request);
        return ResponseEntity.ok(ApiResponse.success(comment));
    }
    
    @PutMapping("/{commentId}")
    public ResponseEntity<ApiResponse<CommentResponse>> updateComment(
            @PathVariable String commentId,
            @RequestHeader("X-User-Id") String userId,
            @RequestBody CommentRequest request) {
        
        CommentResponse comment = commentService.updateComment(commentId, userId, request);
        return ResponseEntity.ok(ApiResponse.success(comment));
    }
    
    @DeleteMapping("/{commentId}")
    public ResponseEntity<ApiResponse<Void>> deleteComment(
            @PathVariable String commentId,
            @RequestHeader("X-User-Id") String userId) {
        
        commentService.deleteComment(commentId, userId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }
    
    @PostMapping("/{commentId}/like")
    public ResponseEntity<ApiResponse<Void>> likeComment(
            @PathVariable String commentId,
            @RequestHeader("X-User-Id") String userId) {
        
        commentService.likeComment(commentId, userId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }
    
    @PostMapping("/{commentId}/unlike")
    public ResponseEntity<ApiResponse<Void>> unlikeComment(
            @PathVariable String commentId,
            @RequestHeader("X-User-Id") String userId) {
        
        commentService.unlikeComment(commentId, userId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }
    
    @GetMapping("/{commentId}")
    public ResponseEntity<ApiResponse<CommentResponse>> getCommentById(@PathVariable String commentId) {
        CommentResponse comment = commentService.getCommentById(commentId);
        return ResponseEntity.ok(ApiResponse.success(comment));
    }
}