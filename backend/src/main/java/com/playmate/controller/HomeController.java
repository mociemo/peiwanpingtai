package com.playmate.controller;

import com.playmate.dto.ApiResponse;
import com.playmate.entity.HomeContent;
import com.playmate.service.HomeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/home")
public class HomeController {

    @Autowired
    private HomeService homeService;

    /**
     * 获取首页置顶内容
     */
    @GetMapping("/featured")
    public ResponseEntity<ApiResponse<List<HomeContent>>> getFeaturedContent() {
        try {
            List<HomeContent> content = homeService.getFeaturedContent();
            return ResponseEntity.ok(ApiResponse.success(content));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 获取首页推荐陪玩人员
     */
    @GetMapping("/recommended-players")
    public ResponseEntity<ApiResponse<List<Object>>> getRecommendedPlayers(
            @RequestParam(defaultValue = "10") int limit) {
        try {
            List<Object> players = homeService.getRecommendedPlayers(limit);
            return ResponseEntity.ok(ApiResponse.success(players));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 获取首页热门动态
     */
    @GetMapping("/hot-posts")
    public ResponseEntity<ApiResponse<List<Object>>> getHotPosts(
            @RequestParam(defaultValue = "10") int limit) {
        try {
            List<Object> posts = homeService.getHotPosts(limit);
            return ResponseEntity.ok(ApiResponse.success(posts));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 添加首页置顶内容（管理员功能）
     */
    @PostMapping("/featured")
    public ResponseEntity<ApiResponse<HomeContent>> addFeaturedContent(@RequestBody HomeContent content) {
        try {
            HomeContent savedContent = homeService.addFeaturedContent(content);
            return ResponseEntity.ok(ApiResponse.success(savedContent));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 更新首页置顶内容（管理员功能）
     */
    @PutMapping("/featured/{id}")
    public ResponseEntity<ApiResponse<HomeContent>> updateFeaturedContent(
            @PathVariable String id, @RequestBody HomeContent content) {
        try {
            HomeContent updatedContent = homeService.updateFeaturedContent(id, content);
            return ResponseEntity.ok(ApiResponse.success(updatedContent));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 删除首页置顶内容（管理员功能）
     */
    @DeleteMapping("/featured/{id}")
    public ResponseEntity<ApiResponse<String>> deleteFeaturedContent(@PathVariable String id) {
        try {
            homeService.deleteFeaturedContent(id);
            return ResponseEntity.ok(ApiResponse.success("删除成功"));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        }
    }
}