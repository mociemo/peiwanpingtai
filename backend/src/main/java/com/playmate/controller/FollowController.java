package com.playmate.controller;

import com.playmate.dto.ApiResponse;
import com.playmate.dto.FollowRequest;
import com.playmate.dto.FollowResponse;
import com.playmate.dto.UserStatsResponse;
import com.playmate.entity.User;
import com.playmate.service.FollowService;
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
@RequestMapping("/api/follows")
@RequiredArgsConstructor
public class FollowController {
    
    private final FollowService followService;
    private final UserService userService;
    
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
            Authentication authentication,
            @PathVariable Long targetUserId) {
        try {
            Long userId = getUserIdFromUsername(authentication.getName());
            boolean isFollowing = followService.isFollowing(userId, targetUserId);
            return ResponseEntity.ok(ApiResponse.success(isFollowing));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("查询关注状态失败: " + e.getMessage()));
        }
    }
    
    @PostMapping
    public ResponseEntity<ApiResponse<FollowResponse>> followUser(
            Authentication authentication,
            @RequestBody FollowRequest request) {
        try {
            Long userId = getUserIdFromUsername(authentication.getName());
            FollowResponse follow = followService.followUser(userId, request.getTargetUserId());
            return ResponseEntity.ok(ApiResponse.success(follow));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("关注失败: " + e.getMessage()));
        }
    }
    
    @DeleteMapping("/{targetUserId}")
    public ResponseEntity<ApiResponse<Void>> unfollowUser(
            Authentication authentication,
            @PathVariable Long targetUserId) {
        try {
            Long userId = getUserIdFromUsername(authentication.getName());
            followService.unfollowUser(userId, targetUserId);
            return ResponseEntity.ok(ApiResponse.success(null));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("取消关注失败: " + e.getMessage()));
        }
    }
    
    @GetMapping("/stats/{userId}")
    public ResponseEntity<ApiResponse<UserStatsResponse>> getUserStats(@PathVariable Long userId) {
        UserStatsResponse stats = followService.getUserStats(userId);
        return ResponseEntity.ok(ApiResponse.success(stats));
    }
    
    @GetMapping("/mutual-followers/{userId}")
    public ResponseEntity<ApiResponse<Page<FollowResponse>>> getMutualFollowers(
            Authentication authentication,
            @PathVariable Long userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        try {
            Long currentUserId = getUserIdFromUsername(authentication.getName());
            Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createTime"));
            Page<FollowResponse> mutualFollowers = followService.getMutualFollowers(currentUserId, userId, pageable);
            return ResponseEntity.ok(ApiResponse.success(mutualFollowers));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取共同关注失败: " + e.getMessage()));
        }
    }
    
    private Long getUserIdFromUsername(String username) {
        User user = userService.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        return user.getId();
    }
}