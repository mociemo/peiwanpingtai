package com.playmate.repository;

import com.playmate.entity.ShareRecord;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ShareRecordRepository extends MongoRepository<ShareRecord, String> {
    
    /**
     * 根据分享ID查找分享记录
     */
    Optional<ShareRecord> findByShareId(String shareId);
    
    /**
     * 统计用户的分享次数
     */
    long countByUserId(String userId);
    
    /**
     * 统计用户特定类型的分享次数
     */
    long countByUserIdAndShareType(String userId, String shareType);
    
    /**
     * 统计用户分享的总浏览次数
     */
    @Query(value = "{ 'userId': ?0 }", fields = "{ 'viewCount': 1 }")
    Integer sumViewCountByUserId(String userId);
}