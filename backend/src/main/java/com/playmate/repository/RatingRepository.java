package com.playmate.repository;

import com.playmate.entity.Rating;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RatingRepository extends MongoRepository<Rating, String> {
    
    /**
     * 根据订单ID查找评价
     */
    Rating findByOrderId(String orderId);
    
    /**
     * 检查订单是否已评价
     */
    boolean existsByOrderId(String orderId);
    
    /**
     * 根据陪玩人员ID查找评价，按创建时间倒序
     */
    List<Rating> findByPlayerIdOrderByCreateTimeDesc(String playerId);
    
    /**
     * 统计陪玩人员的评价数量
     */
    long countByPlayerId(String playerId);
    
    /**
     * 统计陪玩人员的特定星级评价数量
     */
    long countByPlayerIdAndRating(String playerId, Integer rating);
    
    /**
     * 计算陪玩人员的平均评分
     */
    @Query(value = "{ 'playerId': ?0 }", fields = "{ 'rating': 1 }")
    List<Rating> findRatingsByPlayerId(String playerId);
    
    /**
     * 使用聚合管道计算平均评分
     */
    @Query(value = "{ 'playerId': ?0 }", count = true)
    default Double calculateAverageRatingByPlayerId(String playerId) {
        List<Rating> ratings = findRatingsByPlayerId(playerId);
        if (ratings.isEmpty()) {
            return null;
        }
        
        double sum = ratings.stream()
                .mapToInt(Rating::getRating)
                .sum();
                
        return sum / ratings.size();
    }
}