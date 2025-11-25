package com.playmate.controller;

import com.playmate.dto.ApiResponse;
import com.playmate.entity.Feedback.FeedbackStatus;
import com.playmate.service.FeedbackService;
import com.playmate.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/feedback")
@RequiredArgsConstructor
@Slf4j
public class FeedbackController {

    private final FeedbackService feedbackService;
    private final UserService userService;

    /**
     * 提交反馈
     */
    @PostMapping
    public ResponseEntity<ApiResponse<Map<String, Object>>> submitFeedback(
            Authentication authentication,
            @RequestBody Map<String, Object> feedbackData) {
        try {
            String username = authentication.getName();
            Long userId = getUserIdFromUsername(username);
            
            Map<String, Object> result = feedbackService.submitFeedback(userId, feedbackData);
            
            return ResponseEntity.ok(ApiResponse.success(result));
        } catch (Exception e) {
            log.error("提交反馈失败: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().body(ApiResponse.error("提交反馈失败: " + e.getMessage()));
        }
    }

    /**
     * 获取用户反馈历史
     */
    @GetMapping("/history")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getUserFeedbackHistory(
            Authentication authentication,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        try {
            String username = authentication.getName();
            Long userId = getUserIdFromUsername(username);
            
            Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
            Map<String, Object> result = feedbackService.getUserFeedbackHistory(userId, pageable);
            
            return ResponseEntity.ok(ApiResponse.success(result));
        } catch (Exception e) {
            log.error("获取反馈历史失败: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().body(ApiResponse.error("获取反馈历史失败: " + e.getMessage()));
        }
    }

    /**
     * 管理员获取反馈列表
     */
    @GetMapping("/admin/list")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getFeedbackList(
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        try {
            FeedbackStatus feedbackStatus = null;
            if (status != null && !status.isEmpty()) {
                try {
                    feedbackStatus = FeedbackStatus.valueOf(status.toUpperCase());
                } catch (IllegalArgumentException e) {
                    return ResponseEntity.badRequest().body(ApiResponse.error("无效的状态参数"));
                }
            }
            
            Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
            Map<String, Object> result = feedbackService.getFeedbackList(feedbackStatus, pageable);
            
            return ResponseEntity.ok(ApiResponse.success(result));
        } catch (Exception e) {
            log.error("获取反馈列表失败: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().body(ApiResponse.error("获取反馈列表失败: " + e.getMessage()));
        }
    }

    /**
     * 管理员处理反馈
     */
    @PutMapping("/admin/process/{feedbackId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> processFeedback(
            @PathVariable Long feedbackId,
            @RequestBody Map<String, Object> processData) {
        try {
            String statusStr = (String) processData.get("status");
            String adminReply = (String) processData.get("adminReply");
            
            if (statusStr == null || statusStr.isEmpty()) {
                return ResponseEntity.badRequest().body(ApiResponse.error("状态不能为空"));
            }
            
            FeedbackStatus status;
            try {
                status = FeedbackStatus.valueOf(statusStr.toUpperCase());
            } catch (IllegalArgumentException e) {
                return ResponseEntity.badRequest().body(ApiResponse.error("无效的状态参数"));
            }
            
            Map<String, Object> result = feedbackService.processFeedback(feedbackId, status, adminReply);
            
            return ResponseEntity.ok(ApiResponse.success(result));
        } catch (Exception e) {
            log.error("处理反馈失败: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().body(ApiResponse.error("处理反馈失败: " + e.getMessage()));
        }
    }

    /**
     * 获取反馈统计
     */
    @GetMapping("/admin/stats")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getFeedbackStats() {
        try {
            Map<String, Object> stats = feedbackService.getFeedbackStats();
            return ResponseEntity.ok(ApiResponse.success(stats));
        } catch (Exception e) {
            log.error("获取反馈统计失败: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().body(ApiResponse.error("获取反馈统计失败: " + e.getMessage()));
        }
    }

    /**
     * 获取待处理反馈
     */
    @GetMapping("/admin/pending")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getPendingFeedbacks() {
        try {
            Map<String, Object> result = Map.of(
                "pendingFeedbacks", feedbackService.getPendingFeedbacks(),
                "total", feedbackService.getPendingFeedbacks().size()
            );
            
            return ResponseEntity.ok(ApiResponse.success(result));
        } catch (Exception e) {
            log.error("获取待处理反馈失败: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().body(ApiResponse.error("获取待处理反馈失败: " + e.getMessage()));
        }
    }

    /**
     * 从用户名获取用户ID
     */
    private Long getUserIdFromUsername(String username) {
        return userService.getUserIdByUsername(username);
    }
}