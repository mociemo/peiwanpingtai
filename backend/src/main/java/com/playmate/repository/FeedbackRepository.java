package com.playmate.repository;

import com.playmate.entity.Feedback;
import com.playmate.entity.Feedback.FeedbackStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface FeedbackRepository extends JpaRepository<Feedback, Long> {
    
    /**
     * 根据用户ID查找反馈
     */
    Page<Feedback> findByUserIdOrderByCreatedAtDesc(Long userId, Pageable pageable);
    
    /**
     * 根据状态查找反馈
     */
    Page<Feedback> findByStatusOrderByCreatedAtDesc(FeedbackStatus status, Pageable pageable);
    
    /**
     * 根据类型查找反馈
     */
    Page<Feedback> findByTypeOrderByCreatedAtDesc(String type, Pageable pageable);
    
    /**
     * 根据用户ID和状态查找反馈
     */
    Page<Feedback> findByUserIdAndStatusOrderByCreatedAtDesc(Long userId, FeedbackStatus status, Pageable pageable);
    
    /**
     * 查找待处理的反馈
     */
    @Query("SELECT f FROM Feedback f WHERE f.status = 'PENDING' ORDER BY f.createdAt ASC")
    List<Feedback> findPendingFeedbacks();
    
    /**
     * 统计各状态的反馈数量
     */
    @Query("SELECT f.status, COUNT(f) FROM Feedback f GROUP BY f.status")
    List<Object[]> countByStatus();
    
    /**
     * 统计用户反馈数量
     */
    @Query("SELECT COUNT(f) FROM Feedback f WHERE f.userId = :userId")
    long countByUserId(@Param("userId") Long userId);
    
    /**
     * 根据时间范围查找反馈
     */
    @Query("SELECT f FROM Feedback f WHERE f.createdAt BETWEEN :startDate AND :endDate ORDER BY f.createdAt DESC")
    Page<Feedback> findByDateRange(@Param("startDate") LocalDateTime startDate, 
                                  @Param("endDate") LocalDateTime endDate, 
                                  Pageable pageable);
    
    /**
     * 搜索反馈内容
     */
    @Query("SELECT f FROM Feedback f WHERE f.content LIKE %:keyword% OR f.adminReply LIKE %:keyword% ORDER BY f.createdAt DESC")
    Page<Feedback> searchByKeyword(@Param("keyword") String keyword, Pageable pageable);
}