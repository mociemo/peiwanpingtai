package com.playmate.repository;

import com.playmate.entity.GameCategory;
import com.playmate.entity.GameCategory.CategoryStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface GameCategoryRepository extends JpaRepository<GameCategory, Long> {
    
    List<GameCategory> findByStatus(CategoryStatus status);
    
    List<GameCategory> findByStatusOrderBySortOrderAsc(CategoryStatus status);
    
    Optional<GameCategory> findByName(String name);
    
    @Query("SELECT gc FROM GameCategory gc WHERE gc.status = :status ORDER BY gc.sortOrder ASC")
    List<GameCategory> findActiveCategoriesOrderBySort(@Param("status") CategoryStatus status);
    
    @Query("SELECT COUNT(p) FROM Player p WHERE p.gameCategory.id = :categoryId")
    long countPlayersByCategory(@Param("categoryId") Long categoryId);
    
    boolean existsByName(String name);
}