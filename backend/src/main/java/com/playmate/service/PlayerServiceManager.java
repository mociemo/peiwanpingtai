package com.playmate.service;

import com.playmate.entity.User;
import com.playmate.entity.Player;
import com.playmate.entity.PlayerService;
import com.playmate.repository.PlayerRepository;
import com.playmate.repository.PlayerServiceRepository;
import com.playmate.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;

import java.util.List;

@Service
@RequiredArgsConstructor
public class PlayerServiceManager {
    
    private final UserRepository userRepository;
    private final PlayerRepository playerRepository;
    private final PlayerServiceRepository playerServiceRepository;
    
    @Transactional
    public PlayerService addPlayerService(@NonNull Long userId, @NonNull String serviceName, String serviceDescription, 
                                         @NonNull BigDecimal servicePrice, @NonNull Integer durationMinutes, 
                                         @NonNull PlayerService.ServiceType serviceType) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        
        if (!User.UserType.PLAYER.equals(user.getUserType())) {
            throw new RuntimeException("只有陪玩达人才能添加服务");
        }
        
        Player player = playerRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("陪玩达人信息不存在"));
        
        // 检查是否已存在同名服务
        if (playerServiceRepository.findByPlayerIdAndServiceName(player.getId(), serviceName).isPresent()) {
            throw new RuntimeException("服务名称已存在");
        }
        
        PlayerService playerServiceEntity = new PlayerService();
        playerServiceEntity.setPlayer(player);
        playerServiceEntity.setServiceName(serviceName);
        playerServiceEntity.setServiceDescription(serviceDescription);
        playerServiceEntity.setServicePrice(servicePrice);
        playerServiceEntity.setDurationMinutes(durationMinutes);
        playerServiceEntity.setServiceType(serviceType);
        playerServiceEntity.setStatus(PlayerService.ServiceStatus.ACTIVE);
        playerServiceEntity.setMaxOrdersPerDay(10);
        playerServiceEntity.setCurrentOrdersToday(0);
        playerServiceEntity.setTotalOrders(0);
        playerServiceEntity.setRating(BigDecimal.ZERO);
        playerServiceEntity.setRatingCount(0);
        
        return playerServiceRepository.save(playerServiceEntity);
    }
    
    public List<PlayerService> getPlayerServices(@NonNull Long userId) {
        Player player = playerRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("陪玩达人信息不存在"));
        
        return playerServiceRepository.findByPlayerIdAndStatus(player.getId(), PlayerService.ServiceStatus.ACTIVE);
    }
    
    public List<PlayerService> getAllPlayerServices() {
        return playerServiceRepository.findByServiceTypeAndStatus(
            PlayerService.ServiceType.GAME_ACCOMPANY, 
            PlayerService.ServiceStatus.ACTIVE
        );
    }
    
    public List<PlayerService> getServicesByType(PlayerService.ServiceType serviceType) {
        return playerServiceRepository.findByServiceTypeAndStatus(serviceType, PlayerService.ServiceStatus.ACTIVE);
    }
    
    public List<PlayerService> getServicesByPriceRange(@NonNull BigDecimal minPrice, @NonNull BigDecimal maxPrice) {
        return playerServiceRepository.findByPriceRange(minPrice, maxPrice);
    }
    
    @Transactional
    public PlayerService updatePlayerService(@NonNull Long serviceId, @NonNull Long userId, @NonNull String serviceName, 
                                           String serviceDescription, @NonNull BigDecimal servicePrice, 
                                           @NonNull Integer durationMinutes, @NonNull PlayerService.ServiceType serviceType) {
        PlayerService playerServiceEntity = playerServiceRepository.findById(serviceId)
                .orElseThrow(() -> new RuntimeException("服务不存在"));
        
        if (!playerServiceEntity.getPlayer().getUser().getId().equals(userId)) {
            throw new RuntimeException("无权修改此服务");
        }
        
        playerServiceEntity.setServiceName(serviceName);
        playerServiceEntity.setServiceDescription(serviceDescription);
        playerServiceEntity.setServicePrice(servicePrice);
        playerServiceEntity.setDurationMinutes(durationMinutes);
        playerServiceEntity.setServiceType(serviceType);
        
        return playerServiceRepository.save(playerServiceEntity);
    }
    
    @Transactional
    public void deactivatePlayerService(@NonNull Long serviceId, @NonNull Long userId) {
        PlayerService playerServiceEntity = playerServiceRepository.findById(serviceId)
                .orElseThrow(() -> new RuntimeException("服务不存在"));
        
        if (!playerServiceEntity.getPlayer().getUser().getId().equals(userId)) {
            throw new RuntimeException("无权操作此服务");
        }
        
        playerServiceEntity.setStatus(PlayerService.ServiceStatus.INACTIVE);
        playerServiceRepository.save(playerServiceEntity);
    }
    
    @Transactional
    public void activatePlayerService(@NonNull Long serviceId, @NonNull Long userId) {
        PlayerService playerServiceEntity = playerServiceRepository.findById(serviceId)
                .orElseThrow(() -> new RuntimeException("服务不存在"));
        
        if (!playerServiceEntity.getPlayer().getUser().getId().equals(userId)) {
            throw new RuntimeException("无权操作此服务");
        }
        
        playerServiceEntity.setStatus(PlayerService.ServiceStatus.ACTIVE);
        playerServiceRepository.save(playerServiceEntity);
    }
    
    @Transactional
    public void incrementServiceOrderCount(@NonNull Long serviceId) {
        PlayerService playerServiceEntity = playerServiceRepository.findById(serviceId)
                .orElseThrow(() -> new RuntimeException("服务不存在"));
        
        playerServiceEntity.setTotalOrders(playerServiceEntity.getTotalOrders() + 1);
        playerServiceEntity.setCurrentOrdersToday(playerServiceEntity.getCurrentOrdersToday() + 1);
        
        playerServiceRepository.save(playerServiceEntity);
    }
    
    @Transactional
    public void updateServiceRating(@NonNull Long serviceId, @NonNull BigDecimal newRating) {
        PlayerService playerServiceEntity = playerServiceRepository.findById(serviceId)
                .orElseThrow(() -> new RuntimeException("服务不存在"));
        
        int currentCount = playerServiceEntity.getRatingCount();
        BigDecimal currentRating = playerServiceEntity.getRating();
        
        // 计算新的平均评分
        BigDecimal newAverageRating = currentRating.multiply(BigDecimal.valueOf(currentCount))
                .add(newRating)
                .divide(BigDecimal.valueOf(currentCount + 1), 2, RoundingMode.HALF_UP);
        
        playerServiceEntity.setRating(newAverageRating);
        playerServiceEntity.setRatingCount(currentCount + 1);
        
        playerServiceRepository.save(playerServiceEntity);
    }
    
    public PlayerService getServiceById(@NonNull Long serviceId) {
        return playerServiceRepository.findById(serviceId)
                .orElseThrow(() -> new RuntimeException("服务不存在"));
    }
    
    public List<PlayerService> getTopRatedServicesByGame(String game) {
        return playerServiceRepository.findTopRatedServicesByGame(game);
    }
}