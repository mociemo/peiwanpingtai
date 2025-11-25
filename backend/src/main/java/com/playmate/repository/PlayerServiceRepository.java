package com.playmate.repository;

import com.playmate.entity.PlayerService;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Repository
public interface PlayerServiceRepository extends JpaRepository<PlayerService, Long> {
    
    List<PlayerService> findByPlayerIdAndStatus(Long playerId, PlayerService.ServiceStatus status);
    
    List<PlayerService> findByPlayerId(Long playerId);
    
    List<PlayerService> findByServiceTypeAndStatus(PlayerService.ServiceType serviceType, PlayerService.ServiceStatus status);
    
    @Query("SELECT ps FROM PlayerService ps WHERE ps.status = 'ACTIVE' AND ps.servicePrice BETWEEN :minPrice AND :maxPrice")
    List<PlayerService> findByPriceRange(@Param("minPrice") BigDecimal minPrice, @Param("maxPrice") BigDecimal maxPrice);
    
    @Query("SELECT ps FROM PlayerService ps WHERE ps.player.user.id = :playerId AND ps.serviceName = :serviceName")
    Optional<PlayerService> findByPlayerIdAndServiceName(@Param("playerId") Long playerId, @Param("serviceName") String serviceName);
    
    @Query("SELECT COUNT(ps) FROM PlayerService ps WHERE ps.player.user.id = :playerId AND ps.status = 'ACTIVE'")
    Long countActiveServicesByPlayerId(@Param("playerId") Long playerId);
    
    @Query("SELECT ps FROM PlayerService ps WHERE ps.player.game = :game AND ps.status = 'ACTIVE' ORDER BY ps.rating DESC")
    List<PlayerService> findTopRatedServicesByGame(@Param("game") String game);
}