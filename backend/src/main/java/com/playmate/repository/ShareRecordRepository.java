package com.playmate.repository;

import com.playmate.entity.ShareRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ShareRecordRepository extends JpaRepository<ShareRecord, Long> {
    
    /**
     * 根据分享ID查找分享记录
     */
    Optional<ShareRecord> findByShareId(String shareId);
    
    /**
     * 统计用户的分享次数
     */
    long countByUserId(Long userId);
    
    /**
     * 统计用户特定类型的分享次数
     */
    long countByUserIdAndShareType(Long userId, String shareType);
    
    /**
     * 统计用户分享的总浏览次数
     */
    @Query("SELECT SUM(s.viewCount) FROM ShareRecord s WHERE s.userId = :userId")
    Integer sumViewCountByUserId(Long userId);
}