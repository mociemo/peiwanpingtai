package com.playmate.controller;

import com.playmate.dto.ApiResponse;
import com.playmate.dto.CreatePostRequest;
import com.playmate.dto.PostResponse;
import com.playmate.entity.PostStatus;
import com.playmate.entity.PostType;
import com.playmate.service.PostService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/posts")
public class PostController {
    
    private final PostService postService;
    
    public PostController(PostService postService) {
        this.postService = postService;
    }
    
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
            @PathVariable String userId,
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
            @RequestParam List<String> userIds,
            @RequestParam(defaultValue = "PUBLISHED") PostStatus status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createTime"));
        Page<PostResponse> posts = postService.getPostsByUserIds(userIds, status, pageable);
        return ResponseEntity.ok(ApiResponse.success(posts));
    }
    
    @PostMapping
    public ResponseEntity<ApiResponse<PostResponse>> createPost(
            @RequestHeader("X-User-Id") String userId,
            @RequestBody CreatePostRequest request) {
        
        PostResponse post = postService.createPost(userId, request);
        return ResponseEntity.ok(ApiResponse.success(post));
    }
    
    @PutMapping("/{postId}")
    public ResponseEntity<ApiResponse<PostResponse>> updatePost(
            @PathVariable String postId,
            @RequestHeader("X-User-Id") String userId,
            @RequestBody CreatePostRequest request) {
        
        PostResponse post = postService.updatePost(postId, userId, request);
        return ResponseEntity.ok(ApiResponse.success(post));
    }
    
    @DeleteMapping("/{postId}")
    public ResponseEntity<ApiResponse<Void>> deletePost(
            @PathVariable String postId,
            @RequestHeader("X-User-Id") String userId) {
        
        postService.deletePost(postId, userId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }
    
    @PostMapping("/{postId}/like")
    public ResponseEntity<ApiResponse<Void>> likePost(
            @PathVariable String postId,
            @RequestHeader("X-User-Id") String userId) {
        
        postService.likePost(postId, userId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }
    
    @PostMapping("/{postId}/unlike")
    public ResponseEntity<ApiResponse<Void>> unlikePost(
            @PathVariable String postId,
            @RequestHeader("X-User-Id") String userId) {
        
        postService.unlikePost(postId, userId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }
    
    @GetMapping("/{postId}")
    public ResponseEntity<ApiResponse<PostResponse>> getPostById(@PathVariable String postId) {
        PostResponse post = postService.getPostById(postId);
        return ResponseEntity.ok(ApiResponse.success(post));
    }
}