package com.playmate.repository;

import com.playmate.entity.Player;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;

@Repository
public interface PlayerRepository extends JpaRepository<Player, Long> {
    
    @Query("SELECT p FROM Player p WHERE p.skillTags LIKE %:game%")
    List<Player> findByGameContainingIgnoreCase(@Param("game") String game);
    
    @Query("SELECT p FROM Player p WHERE p.servicePrice BETWEEN :minPrice AND :maxPrice")
    List<Player> findByPriceBetween(@Param("minPrice") BigDecimal minPrice, 
                                   @Param("maxPrice") BigDecimal maxPrice);
    
    @Query("SELECT p FROM Player p WHERE p.rating >= :minRating")
    List<Player> findByRatingGreaterThanEqual(@Param("minRating") BigDecimal minRating);
    
    @Query("SELECT p FROM Player p ORDER BY p.rating DESC, p.totalOrders DESC")
    List<Player> findTopPlayers();
    
    @Query("SELECT p FROM Player p WHERE p.skillTags LIKE %:game% AND p.servicePrice BETWEEN :minPrice AND :maxPrice")
    List<Player> findByGameAndPriceRange(@Param("game") String game, 
                                       @Param("minPrice") BigDecimal minPrice, 
                                       @Param("maxPrice") BigDecimal maxPrice);
}