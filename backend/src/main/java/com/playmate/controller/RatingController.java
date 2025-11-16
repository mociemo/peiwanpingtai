package com.playmate.controller;

import com.playmate.dto.ApiResponse;
import com.playmate.dto.RatingRequest;
import com.playmate.dto.RatingResponse;
import com.playmate.service.RatingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/ratings")
public class RatingController {

    @Autowired
    private RatingService ratingService;

    /**
     * 创建评价
     */
    @PostMapping
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<RatingResponse>> createRating(@RequestBody RatingRequest request) {
        try {
            RatingResponse response = ratingService.createRating(request);
            return ResponseEntity.ok(ApiResponse.success(response));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 获取用户的所有评价
     */
    @GetMapping("/user/{userId}")
    public ResponseEntity<ApiResponse<List<RatingResponse>>> getUserRatings(
            @PathVariable String userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        try {
            List<RatingResponse> response = ratingService.getUserRatings(userId, page, size);
            return ResponseEntity.ok(ApiResponse.success(response));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 获取陪玩人员的平均评分
     */
    @GetMapping("/average/{playerId}")
    public ResponseEntity<ApiResponse<Double>> getPlayerAverageRating(@PathVariable String playerId) {
        try {
            Double averageRating = ratingService.getPlayerAverageRating(playerId);
            return ResponseEntity.ok(ApiResponse.success(averageRating));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 获取陪玩人员的评分统计
     */
    @GetMapping("/stats/{playerId}")
    public ResponseEntity<ApiResponse<Object>> getPlayerRatingStats(@PathVariable String playerId) {
        try {
            Object stats = ratingService.getPlayerRatingStats(playerId);
            return ResponseEntity.ok(ApiResponse.success(stats));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        }
    }
}