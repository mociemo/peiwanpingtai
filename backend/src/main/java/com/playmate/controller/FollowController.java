package com.playmate.controller;

import com.playmate.dto.ApiResponse;
import com.playmate.dto.FollowRequest;
import com.playmate.dto.FollowResponse;
import com.playmate.dto.UserStatsResponse;
import com.playmate.service.FollowService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/follows")
@RequiredArgsConstructor
public class FollowController {
    
    private final FollowService followService;
    
    @GetMapping("/followers/{userId}")
    public ResponseEntity<ApiResponse<Page<FollowResponse>>> getFollowers(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createTime"));
        Page<FollowResponse> followers = followService.getFollowers(userId, pageable);
        return ResponseEntity.ok(ApiResponse.success(followers));
    }
    
    @GetMapping("/following/{userId}")
    public ResponseEntity<ApiResponse<Page<FollowResponse>>> getFollowing(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createTime"));
        Page<FollowResponse> following = followService.getFollowing(userId, pageable);
        return ResponseEntity.ok(ApiResponse.success(following));
    }
    
    @GetMapping("/is-following/{targetUserId}")
    public ResponseEntity<ApiResponse<Boolean>> isFollowing(
            @RequestHeader("X-User-Id") Long userId,
            @PathVariable Long targetUserId) {
        
        boolean isFollowing = followService.isFollowing(userId, targetUserId);
        return ResponseEntity.ok(ApiResponse.success(isFollowing));
    }
    
    @PostMapping
    public ResponseEntity<ApiResponse<FollowResponse>> followUser(
            @RequestHeader("X-User-Id") Long userId,
            @RequestBody FollowRequest request) {
        
        FollowResponse follow = followService.followUser(userId, request.getTargetUserId());
        return ResponseEntity.ok(ApiResponse.success(follow));
    }
    
    @DeleteMapping("/{targetUserId}")
    public ResponseEntity<ApiResponse<Void>> unfollowUser(
            @RequestHeader("X-User-Id") Long userId,
            @PathVariable Long targetUserId) {
        
        followService.unfollowUser(userId, targetUserId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }
    
    @GetMapping("/stats/{userId}")
    public ResponseEntity<ApiResponse<UserStatsResponse>> getUserStats(@PathVariable Long userId) {
        UserStatsResponse stats = followService.getUserStats(userId);
        return ResponseEntity.ok(ApiResponse.success(stats));
    }
    
    @GetMapping("/mutual-followers/{userId}")
    public ResponseEntity<ApiResponse<Page<FollowResponse>>> getMutualFollowers(
            @RequestHeader("X-User-Id") Long currentUserId,
            @PathVariable Long userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createTime"));
        Page<FollowResponse> mutualFollowers = followService.getMutualFollowers(currentUserId, userId, pageable);
        return ResponseEntity.ok(ApiResponse.success(mutualFollowers));
    }
}