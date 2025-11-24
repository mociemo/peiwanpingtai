package com.playmate.repository;

import com.playmate.entity.Order;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {
    
    @Query("SELECT o FROM Order o WHERE o.user.id = :userId ORDER BY o.createTime DESC")
    List<Order> findByUserIdOrderByCreateTimeDesc(@Param("userId") Long userId);
    
    @Query("SELECT o FROM Order o WHERE o.player.id = :playerId ORDER BY o.createTime DESC")
    List<Order> findByPlayerIdOrderByCreateTimeDesc(@Param("playerId") Long playerId);
    
    @Query("SELECT o FROM Order o WHERE o.user.id = :userId AND o.status = :status ORDER BY o.createTime DESC")
    List<Order> findByUserIdAndStatus(@Param("userId") Long userId, @Param("status") Order.OrderStatus status);
    
    @Query("SELECT o FROM Order o WHERE o.player.id = :playerId AND o.status = :status ORDER BY o.createTime DESC")
    List<Order> findByPlayerIdAndStatus(@Param("playerId") Long playerId, @Param("status") Order.OrderStatus status);
    
    @Query("SELECT COUNT(o) FROM Order o WHERE o.player.id = :playerId AND o.status = 'COMPLETED'")
    Long countCompletedOrdersByPlayerId(@Param("playerId") Long playerId);
    
    @Query("SELECT AVG(CAST(o.rating AS double)) FROM Order o WHERE o.player.id = :playerId AND o.rating IS NOT NULL")
    Double getAverageRatingByPlayerId(@Param("playerId") Long playerId);
}