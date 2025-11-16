package com.playmate.service;

import com.playmate.dto.RatingRequest;
import com.playmate.dto.RatingResponse;
import com.playmate.entity.Rating;
import com.playmate.entity.Order;
import com.playmate.entity.User;
import com.playmate.repository.RatingRepository;
import com.playmate.repository.OrderRepository;
import com.playmate.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class RatingService {

    @Autowired
    private RatingRepository ratingRepository;

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private UserRepository userRepository;

    /**
     * 创建评价
     */
    public RatingResponse createRating(RatingRequest request) {
        // 验证订单是否存在且已完成
        Order order = orderRepository.findById(request.getOrderId())
                .orElseThrow(() -> new RuntimeException("订单不存在"));

        if (!order.getStatus().equals("completed")) {
            throw new RuntimeException("只能评价已完成的订单");
        }

        // 检查是否已经评价过
        if (ratingRepository.existsByOrderId(request.getOrderId())) {
            throw new RuntimeException("该订单已经评价过了");
        }

        // 获取评价者和被评价者信息
        User rater = userRepository.findById(order.getUserId())
                .orElseThrow(() -> new RuntimeException("评价者不存在"));

        User player = userRepository.findById(order.getPlayerId())
                .orElseThrow(() -> new RuntimeException("被评价者不存在"));

        // 创建评价
        Rating rating = new Rating();
        rating.setOrderId(request.getOrderId());
        rating.setRaterId(rater.getId());
        rating.setPlayerId(player.getId());
        rating.setRating(request.getRating());
        rating.setComment(request.getComment());
        rating.setTags(request.getTags());
        rating.setCreateTime(LocalDateTime.now());

        rating = ratingRepository.save(rating);

        // 更新订单评价状态
        order.setRating(request.getRating());
        order.setComment(request.getComment());
        order.setCommentTime(LocalDateTime.now());
        orderRepository.save(order);

        // 返回评价响应
        return convertToResponse(rating, rater, player);
    }

    /**
     * 获取用户的所有评价
     */
    public List<RatingResponse> getUserRatings(String userId, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<Rating> ratings = ratingRepository.findByPlayerIdOrderByCreateTimeDesc(userId, pageable);

        return ratings.getContent().stream()
                .map(rating -> {
                    User rater = userRepository.findById(rating.getRaterId()).orElse(null);
                    User player = userRepository.findById(rating.getPlayerId()).orElse(null);
                    return convertToResponse(rating, rater, player);
                })
                .collect(Collectors.toList());
    }

    /**
     * 获取陪玩人员的平均评分
     */
    public Double getPlayerAverageRating(String playerId) {
        return ratingRepository.calculateAverageRatingByPlayerId(playerId);
    }

    /**
     * 获取陪玩人员的评分统计
     */
    public Map<String, Object> getPlayerRatingStats(String playerId) {
        Map<String, Object> stats = new HashMap<>();
        
        // 平均评分
        Double averageRating = getPlayerAverageRating(playerId);
        stats.put("averageRating", averageRating != null ? averageRating : 0.0);
        
        // 总评价数
        Long totalRatings = ratingRepository.countByPlayerId(playerId);
        stats.put("totalRatings", totalRatings);
        
        // 各星级评价数量
        Map<Integer, Long> ratingCounts = new HashMap<>();
        for (int i = 1; i <= 5; i++) {
            Long count = ratingRepository.countByPlayerIdAndRating(playerId, i);
            ratingCounts.put(i, count);
        }
        stats.put("ratingCounts", ratingCounts);
        
        return stats;
    }

    /**
     * 转换为响应对象
     */
    private RatingResponse convertToResponse(Rating rating, User rater, User player) {
        RatingResponse response = new RatingResponse();
        response.setId(rating.getId());
        response.setOrderId(rating.getOrderId());
        response.setRaterId(rating.getRaterId());
        response.setRaterName(rater != null ? rater.getNickname() : "");
        response.setRaterAvatar(rater != null ? rater.getAvatar() : "");
        response.setPlayerId(rating.getPlayerId());
        response.setPlayerName(player != null ? player.getNickname() : "");
        response.setRating(rating.getRating());
        response.setComment(rating.getComment());
        response.setTags(rating.getTags());
        response.setCreateTime(rating.getCreateTime());
        return response;
    }
}