package com.playmate.service;

import com.playmate.entity.Feedback;
import com.playmate.entity.Feedback.FeedbackStatus;
import com.playmate.repository.FeedbackRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
@SuppressWarnings("null")
public class FeedbackService {

    private final FeedbackRepository feedbackRepository;

    /**
     * 提交反馈
     */
    @Transactional
    public Map<String, Object> submitFeedback(Long userId, Map<String, Object> feedbackData) {
        try {
            Feedback feedback = Feedback.builder()
                    .userId(userId)
                    .type((String) feedbackData.get("type"))
                    .content((String) feedbackData.get("content"))
                    .contact((String) feedbackData.get("contact"))
                    .status(FeedbackStatus.PENDING)
                    .build();
            
            Feedback savedFeedback = feedbackRepository.save(feedback);
            
            log.info("用户 {} 提交反馈成功，反馈ID: {}", userId, savedFeedback.getId());
            
            return convertToResponse(savedFeedback);
            
        } catch (Exception e) {
            log.error("提交反馈失败: {}", e.getMessage(), e);
            throw new RuntimeException("提交反馈失败: " + e.getMessage());
        }
    }

    /**
     * 获取用户反馈历史
     */
    public Map<String, Object> getUserFeedbackHistory(Long userId, Pageable pageable) {
        try {
            Page<Feedback> feedbackPage = feedbackRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable);
            
            Map<String, Object> result = new HashMap<>();
            result.put("feedbacks", feedbackPage.getContent().stream()
                    .map(this::convertToResponse)
                    .toList());
            result.put("total", feedbackPage.getTotalElements());
            result.put("page", feedbackPage.getNumber());
            result.put("size", feedbackPage.getSize());
            result.put("totalPages", feedbackPage.getTotalPages());
            
            return result;
            
        } catch (Exception e) {
            log.error("获取用户反馈历史失败: {}", e.getMessage(), e);
            throw new RuntimeException("获取反馈历史失败: " + e.getMessage());
        }
    }

    /**
     * 管理员获取反馈列表
     */
    public Map<String, Object> getFeedbackList(FeedbackStatus status, Pageable pageable) {
        try {
            Page<Feedback> feedbackPage;
            
            if (status != null) {
                feedbackPage = feedbackRepository.findByStatusOrderByCreatedAtDesc(status, pageable);
            } else {
                feedbackPage = feedbackRepository.findAll(pageable);
            }
            
            Map<String, Object> result = new HashMap<>();
            result.put("feedbacks", feedbackPage.getContent().stream()
                    .map(this::convertToResponse)
                    .toList());
            result.put("total", feedbackPage.getTotalElements());
            result.put("page", feedbackPage.getNumber());
            result.put("size", feedbackPage.getSize());
            result.put("totalPages", feedbackPage.getTotalPages());
            
            return result;
            
        } catch (Exception e) {
            log.error("获取反馈列表失败: {}", e.getMessage(), e);
            throw new RuntimeException("获取反馈列表失败: " + e.getMessage());
        }
    }

    /**
     * 处理反馈
     */
    @Transactional
    public Map<String, Object> processFeedback(Long feedbackId, FeedbackStatus status, String adminReply) {
        try {
            Optional<Feedback> optionalFeedback = feedbackRepository.findById(feedbackId);
            
            if (optionalFeedback.isEmpty()) {
                throw new RuntimeException("反馈不存在");
            }
            
            Feedback feedback = optionalFeedback.get();
            feedback.setStatus(status);
            feedback.setAdminReply(adminReply);
            
            Feedback updatedFeedback = feedbackRepository.save(feedback);
            
            log.info("反馈 {} 处理完成，状态: {}", feedbackId, status);
            
            return convertToResponse(updatedFeedback);
            
        } catch (Exception e) {
            log.error("处理反馈失败: {}", e.getMessage(), e);
            throw new RuntimeException("处理反馈失败: " + e.getMessage());
        }
    }

    /**
     * 获取反馈统计
     */
    public Map<String, Object> getFeedbackStats() {
        try {
            List<Object[]> statusCounts = feedbackRepository.countByStatus();
            
            Map<String, Object> stats = new HashMap<>();
            stats.put("total", feedbackRepository.count());
            
            for (Object[] row : statusCounts) {
                String status = (String) row[0];
                Long count = (Long) row[1];
                stats.put(status.toLowerCase(), count);
            }
            
            return stats;
            
        } catch (Exception e) {
            log.error("获取反馈统计失败: {}", e.getMessage(), e);
            throw new RuntimeException("获取反馈统计失败: " + e.getMessage());
        }
    }

    /**
     * 获取待处理反馈
     */
    public List<Map<String, Object>> getPendingFeedbacks() {
        try {
            List<Feedback> pendingFeedbacks = feedbackRepository.findPendingFeedbacks();
            
            return pendingFeedbacks.stream()
                    .map(this::convertToResponse)
                    .toList();
            
        } catch (Exception e) {
            log.error("获取待处理反馈失败: {}", e.getMessage(), e);
            throw new RuntimeException("获取待处理反馈失败: " + e.getMessage());
        }
    }

    /**
     * 转换为响应格式
     */
    private Map<String, Object> convertToResponse(Feedback feedback) {
        Map<String, Object> response = new HashMap<>();
        response.put("id", feedback.getId());
        response.put("userId", feedback.getUserId());
        response.put("type", feedback.getType());
        response.put("content", feedback.getContent());
        response.put("contact", feedback.getContact());
        response.put("status", feedback.getStatus().name());
        response.put("adminReply", feedback.getAdminReply());
        response.put("createdAt", feedback.getCreatedAt());
        response.put("updatedAt", feedback.getUpdatedAt());
        return response;
    }
}