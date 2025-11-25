package com.playmate.controller;

import com.playmate.dto.ApiResponse;
import com.playmate.entity.GameCategory;
import com.playmate.entity.GameCategory.CategoryStatus;
import com.playmate.service.GameCategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/game-categories")
@RequiredArgsConstructor
public class GameCategoryController {
    
    private final GameCategoryService gameCategoryService;
    
    @GetMapping
    public ResponseEntity<ApiResponse<List<GameCategory>>> getAllActiveCategories() {
        try {
            List<GameCategory> categories = gameCategoryService.getAllCategories();
            return ResponseEntity.ok(ApiResponse.success("获取游戏分类成功", categories));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @GetMapping("/all")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<List<GameCategory>>> getAllCategories() {
        try {
            List<GameCategory> categories = gameCategoryService.getAllCategoriesWithInactive();
            return ResponseEntity.ok(ApiResponse.success("获取所有游戏分类成功", categories));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<GameCategory>> getCategoryById(@PathVariable Long id) {
        try {
            Optional<GameCategory> category = gameCategoryService.getCategoryById(id);
            if (category.isPresent()) {
                return ResponseEntity.ok(ApiResponse.success("获取游戏分类成功", category.get()));
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @GetMapping("/name/{name}")
    public ResponseEntity<ApiResponse<GameCategory>> getCategoryByName(@PathVariable String name) {
        try {
            Optional<GameCategory> category = gameCategoryService.getCategoryByName(name);
            if (category.isPresent()) {
                return ResponseEntity.ok(ApiResponse.success("获取游戏分类成功", category.get()));
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<GameCategory>> createCategory(@RequestBody GameCategory category) {
        try {
            GameCategory createdCategory = gameCategoryService.createCategory(category);
            return ResponseEntity.ok(ApiResponse.success("创建游戏分类成功", createdCategory));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<GameCategory>> updateCategory(
            @PathVariable Long id, 
            @RequestBody GameCategory category) {
        try {
            GameCategory updatedCategory = gameCategoryService.updateCategory(id, category);
            return ResponseEntity.ok(ApiResponse.success("更新游戏分类成功", updatedCategory));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @SuppressWarnings("null")
    public ResponseEntity<ApiResponse<String>> deleteCategory(@PathVariable Long id) {
        try {
            gameCategoryService.deleteCategory(id);
            return ResponseEntity.ok(ApiResponse.success("删除游戏分类成功"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PutMapping("/{id}/activate")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<GameCategory>> activateCategory(@PathVariable Long id) {
        try {
            GameCategory category = gameCategoryService.activateCategory(id);
            return ResponseEntity.ok(ApiResponse.success("激活游戏分类成功", category));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PutMapping("/{id}/deactivate")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<GameCategory>> deactivateCategory(@PathVariable Long id) {
        try {
            GameCategory category = gameCategoryService.deactivateCategory(id);
            return ResponseEntity.ok(ApiResponse.success("停用游戏分类成功", category));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @GetMapping("/status/{status}")
    public ResponseEntity<ApiResponse<List<GameCategory>>> getCategoriesByStatus(@PathVariable CategoryStatus status) {
        try {
            List<GameCategory> categories = gameCategoryService.getCategoriesByStatus(status);
            return ResponseEntity.ok(ApiResponse.success("获取游戏分类成功", categories));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
}