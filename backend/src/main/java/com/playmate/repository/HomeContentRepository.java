package com.playmate.repository;

import com.playmate.entity.HomeContent;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface HomeContentRepository extends MongoRepository<HomeContent, String> {
    
    /**
     * 获取当前有效的首页置顶内容，按排序顺序排序
     */
    List<HomeContent> findByIsActiveTrueAndStartTimeBeforeAndEndTimeAfterOrderBySortOrderAsc(
            LocalDateTime startTime, LocalDateTime endTime);
}