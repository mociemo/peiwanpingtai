package com.playmate.service;

import com.playmate.dto.CreateOrderRequest;
import com.playmate.dto.OrderResponse;
import com.playmate.entity.Order;
import com.playmate.entity.Player;
import com.playmate.entity.User;
import com.playmate.repository.OrderRepository;
import com.playmate.repository.PlayerRepository;
import com.playmate.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.lang.NonNull;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class OrderService {
    
    private final OrderRepository orderRepository;
    private final UserRepository userRepository;
    private final PlayerRepository playerRepository;
    
    @Transactional
    public OrderResponse createOrder(@NonNull Long userId, @NonNull CreateOrderRequest request) {
        // 参数验证
        validateOrderRequest(userId, request);
        
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("用户不存在"));
            
        Long playerId = request.getPlayerId();
        if (playerId == null) {
            throw new RuntimeException("陪玩达人ID不能为空");
        }
        Player player = playerRepository.findById(playerId)
            .orElseThrow(() -> new RuntimeException("陪玩达人不存在"));
        
        // 验证价格（防止价格篡改）
        BigDecimal expectedAmount = calculateOrderAmount(player.getServicePrice(), request.getDuration());
        if (request.getAmount().compareTo(expectedAmount) != 0) {
            log.warn("订单金额异常：用户ID {}, 期望金额 {}, 实际金额 {}", 
                    userId, expectedAmount, request.getAmount());
            throw new RuntimeException("订单金额不正确，请重新下单");
        }
        
        // 验证陪玩达人状态
        if (player.getUser().getStatus() != User.UserStatus.ACTIVE) {
            throw new RuntimeException("陪玩达人当前不可用");
        }
        
        Order order = new Order();
        order.setOrderNo(generateOrderNo());
        order.setUser(user);
        order.setPlayer(player.getUser());
        order.setAmount(request.getAmount());
        order.setDuration(request.getDuration());
        order.setStatus(Order.OrderStatus.PENDING);
        order.setServiceType(Order.ServiceType.valueOf(request.getServiceType()));
        order.setRequirements(request.getRequirements());
        order.setContactInfo(request.getContactInfo());
        order.setCreateTime(LocalDateTime.now());
        
        Order savedOrder = orderRepository.save(order);
        return convertToResponse(savedOrder);
    }
    
    @Transactional
    public OrderResponse acceptOrder(Long orderId, Long playerId) {
        if (orderId == null || playerId == null) {
            throw new IllegalArgumentException("参数不能为空");
        }
        
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new RuntimeException("订单不存在"));
            
        if (!order.getPlayer().getId().equals(playerId)) {
            throw new RuntimeException("无权操作此订单");
        }
        
        if (order.getStatus() != Order.OrderStatus.PENDING) {
            throw new RuntimeException("订单状态不正确");
        }
        
        order.setStatus(Order.OrderStatus.ACCEPTED);
        order.setStartTime(LocalDateTime.now());
        
        Order updatedOrder = orderRepository.save(order);
        return convertToResponse(updatedOrder);
    }
    
    @Transactional
    public OrderResponse startOrder(Long orderId, Long playerId) {
        if (orderId == null || playerId == null) {
            throw new IllegalArgumentException("参数不能为空");
        }
        
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new RuntimeException("订单不存在"));
            
        if (!order.getPlayer().getId().equals(playerId)) {
            throw new RuntimeException("无权操作此订单");
        }
        
        if (order.getStatus() != Order.OrderStatus.ACCEPTED) {
            throw new RuntimeException("订单状态不正确");
        }
        
        order.setStatus(Order.OrderStatus.IN_PROGRESS);
        
        Order updatedOrder = orderRepository.save(order);
        return convertToResponse(updatedOrder);
    }
    
    @Transactional
    public OrderResponse completeOrder(Long orderId, Long playerId) {
        if (orderId == null || playerId == null) {
            throw new IllegalArgumentException("参数不能为空");
        }
        
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new RuntimeException("订单不存在"));
            
        if (!order.getPlayer().getId().equals(playerId)) {
            throw new RuntimeException("无权操作此订单");
        }
        
        if (order.getStatus() != Order.OrderStatus.IN_PROGRESS) {
            throw new RuntimeException("订单状态不正确");
        }
        
        order.setStatus(Order.OrderStatus.COMPLETED);
        order.setEndTime(LocalDateTime.now());
        
        Order updatedOrder = orderRepository.save(order);
        return convertToResponse(updatedOrder);
    }
    
    @Transactional
    public OrderResponse cancelOrder(Long orderId, Long userId, String reason) {
        if (orderId == null || userId == null) {
            throw new IllegalArgumentException("参数不能为空");
        }
        
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new RuntimeException("订单不存在"));
            
        if (!order.getUser().getId().equals(userId)) {
            throw new RuntimeException("无权操作此订单");
        }
        
        if (order.getStatus() != Order.OrderStatus.PENDING && 
            order.getStatus() != Order.OrderStatus.ACCEPTED) {
            throw new RuntimeException("订单状态不正确");
        }
        
        order.setStatus(Order.OrderStatus.CANCELLED);
        order.setCancelReason(reason);
        
        Order updatedOrder = orderRepository.save(order);
        return convertToResponse(updatedOrder);
    }
    
    @Transactional
    public OrderResponse rateOrder(Long orderId, Long userId, String rating, String comment) {
        if (orderId == null || userId == null) {
            throw new IllegalArgumentException("参数不能为空");
        }
        
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new RuntimeException("订单不存在"));
            
        if (!order.getUser().getId().equals(userId)) {
            throw new RuntimeException("无权操作此订单");
        }
        
        if (order.getStatus() != Order.OrderStatus.COMPLETED) {
            throw new RuntimeException("订单状态不正确");
        }
        
        order.setRating(rating);
        order.setComment(comment);
        order.setCommentTime(LocalDateTime.now());
        
        Order updatedOrder = orderRepository.save(order);
        return convertToResponse(updatedOrder);
    }
    
    public List<OrderResponse> getUserOrders(Long userId) {
        List<Order> orders = orderRepository.findByUserIdOrderByCreateTimeDesc(userId);
        return orders.stream()
            .map(this::convertToResponse)
            .collect(Collectors.toList());
    }
    
    public List<OrderResponse> getPlayerOrders(Long playerId) {
        List<Order> orders = orderRepository.findByPlayerIdOrderByCreateTimeDesc(playerId);
        return orders.stream()
            .map(this::convertToResponse)
            .collect(Collectors.toList());
    }
    
    public OrderResponse getOrderById(Long orderId) {
        if (orderId == null) {
            throw new IllegalArgumentException("订单ID不能为空");
        }
        
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new RuntimeException("订单不存在"));
        return convertToResponse(order);
    }
    
    private void validateOrderRequest(Long userId, CreateOrderRequest request) {
        if (userId == null) {
            throw new IllegalArgumentException("用户ID不能为空");
        }
        if (request == null) {
            throw new IllegalArgumentException("订单请求不能为空");
        }
        if (request.getPlayerId() == null) {
            throw new IllegalArgumentException("陪玩达人ID不能为空");
        }
        if (request.getDuration() == null || request.getDuration() <= 0) {
            throw new IllegalArgumentException("服务时长必须大于0");
        }
        if (request.getDuration() > 480) { // 最多8小时
            throw new IllegalArgumentException("单次服务时长不能超过8小时");
        }
        if (request.getAmount() == null || request.getAmount().compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("订单金额必须大于0");
        }
        if (request.getServiceType() == null || request.getServiceType().trim().isEmpty()) {
            throw new IllegalArgumentException("服务类型不能为空");
        }
    }
    
    private BigDecimal calculateOrderAmount(BigDecimal servicePrice, Integer duration) {
        // 按小时计算，不足1小时按1小时计算
        BigDecimal hours = BigDecimal.valueOf(Math.ceil(duration / 60.0));
        return servicePrice.multiply(hours).setScale(2, java.math.RoundingMode.HALF_UP);
    }
    
    private String generateOrderNo() {
        // 使用更安全的订单号生成策略
        return "PM" + System.currentTimeMillis() + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }
    
    private OrderResponse convertToResponse(Order order) {
        OrderResponse response = new OrderResponse();
        response.setId(order.getId());
        response.setOrderNo(order.getOrderNo());
        response.setAmount(order.getAmount());
        response.setDuration(order.getDuration());
        response.setStatus(order.getStatus());
        response.setServiceType(order.getServiceType());
        response.setRequirements(order.getRequirements());
        response.setContactInfo(order.getContactInfo());
        response.setCreateTime(order.getCreateTime());
        response.setStartTime(order.getStartTime());
        response.setEndTime(order.getEndTime());
        response.setCancelReason(order.getCancelReason());
        response.setRating(order.getRating());
        response.setComment(order.getComment());
        response.setCommentTime(order.getCommentTime());
        
        // 设置用户信息（添加null检查）
        OrderResponse.UserInfo userInfo = new OrderResponse.UserInfo();
        if (order.getUser() != null) {
            userInfo.setId(order.getUser().getId() != null ? order.getUser().getId() : 0L);
            userInfo.setUsername(order.getUser().getUsername() != null ? order.getUser().getUsername() : "");
            userInfo.setAvatar(order.getUser().getAvatar() != null ? order.getUser().getAvatar() : "");
        }
        response.setUser(userInfo);
        
        // 设置陪玩达人信息（添加null检查）
        OrderResponse.PlayerInfo playerInfo = new OrderResponse.PlayerInfo();
        if (order.getPlayer() != null) {
            playerInfo.setId(order.getPlayer().getId() != null ? order.getPlayer().getId() : 0L);
            playerInfo.setUsername(order.getPlayer().getUsername() != null ? order.getPlayer().getUsername() : "");
            playerInfo.setAvatar(order.getPlayer().getAvatar() != null ? order.getPlayer().getAvatar() : "");
            // 从Player实体获取游戏和价格信息
            Player playerEntity = playerRepository.findByUserId(order.getPlayer().getId()).orElse(null);
            if (playerEntity != null) {
                playerInfo.setGame(playerEntity.getGame() != null ? playerEntity.getGame() : "");
                playerInfo.setPrice(playerEntity.getServicePrice() != null ? playerEntity.getServicePrice() : BigDecimal.ZERO);
            } else {
                playerInfo.setGame("");
                playerInfo.setPrice(BigDecimal.ZERO);
            }
        }
        response.setPlayer(playerInfo);
        
        return response;
    }
}