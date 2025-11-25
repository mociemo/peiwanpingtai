package com.playmate.service;

import com.playmate.entity.GameCategory;
import com.playmate.entity.GameCategory.CategoryStatus;
import com.playmate.repository.GameCategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional
public class GameCategoryService {
    
    private final GameCategoryRepository gameCategoryRepository;
    
    public List<GameCategory> getAllCategories() {
        return gameCategoryRepository.findByStatusOrderBySortOrderAsc(CategoryStatus.ACTIVE);
    }
    
    public List<GameCategory> getAllCategoriesWithInactive() {
        return gameCategoryRepository.findAll();
    }
    
    @SuppressWarnings("null")
    public Optional<GameCategory> getCategoryById(Long id) {
        return gameCategoryRepository.findById(id);
    }
    
    public Optional<GameCategory> getCategoryByName(String name) {
        return gameCategoryRepository.findByName(name);
    }
    
    public GameCategory createCategory(GameCategory category) {
        if (gameCategoryRepository.existsByName(category.getName())) {
            throw new RuntimeException("游戏分类名称已存在: " + category.getName());
        }
        return gameCategoryRepository.save(category);
    }
    
    @SuppressWarnings("null")
    public GameCategory updateCategory(Long id, GameCategory categoryDetails) {
        return gameCategoryRepository.findById(id)
            .map(category -> {
                // 检查名称是否重复（排除自己）
                Optional<GameCategory> existingCategory = gameCategoryRepository.findByName(categoryDetails.getName());
                if (existingCategory.isPresent() && !existingCategory.get().getId().equals(id)) {
                    throw new RuntimeException("游戏分类名称已存在: " + categoryDetails.getName());
                }
                
                category.setName(categoryDetails.getName());
                category.setDescription(categoryDetails.getDescription());
                category.setIconUrl(categoryDetails.getIconUrl());
                category.setSortOrder(categoryDetails.getSortOrder());
                category.setStatus(categoryDetails.getStatus());
                return gameCategoryRepository.save(category);
            })
            .orElseThrow(() -> new RuntimeException("游戏分类不存在，ID: " + id));
    }
    
    @SuppressWarnings("null")
    public void deleteCategory(Long id) {
        if (!gameCategoryRepository.existsById(id)) {
            throw new RuntimeException("游戏分类不存在，ID: " + id);
        }
        
        long playerCount = gameCategoryRepository.countPlayersByCategory(id);
        if (playerCount > 0) {
            throw new RuntimeException("该分类下还有 " + playerCount + " 个陪玩达人，无法删除");
        }
        
        gameCategoryRepository.deleteById(id);
    }
    
    @SuppressWarnings("null")
    public GameCategory activateCategory(Long id) {
        return gameCategoryRepository.findById(id)
            .map(category -> {
                category.setStatus(CategoryStatus.ACTIVE);
                return gameCategoryRepository.save(category);
            })
            .orElseThrow(() -> new RuntimeException("游戏分类不存在，ID: " + id));
    }
    
    @SuppressWarnings("null")
    public GameCategory deactivateCategory(Long id) {
        return gameCategoryRepository.findById(id)
            .map(category -> {
                category.setStatus(CategoryStatus.INACTIVE);
                return gameCategoryRepository.save(category);
            })
            .orElseThrow(() -> new RuntimeException("游戏分类不存在，ID: " + id));
    }
    
    public List<GameCategory> getCategoriesByStatus(CategoryStatus status) {
        return gameCategoryRepository.findByStatusOrderBySortOrderAsc(status);
    }
}