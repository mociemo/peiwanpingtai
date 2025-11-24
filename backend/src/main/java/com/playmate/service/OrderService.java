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
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OrderService {
    
    private final OrderRepository orderRepository;
    private final UserRepository userRepository;
    private final PlayerRepository playerRepository;
    
    @Transactional
    public OrderResponse createOrder(Long userId, CreateOrderRequest request) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("用户不存在"));
            
        Player player = playerRepository.findById(request.getPlayerId())
            .orElseThrow(() -> new RuntimeException("陪玩达人不存在"));
        
        // 验证价格
        BigDecimal expectedAmount = player.getServicePrice().multiply(BigDecimal.valueOf(request.getDuration() / 60.0));
        if (request.getAmount().compareTo(expectedAmount) != 0) {
            throw new RuntimeException("订单金额不正确");
        }
        
        Order order = new Order();
        order.setOrderNo(generateOrderNo());
        order.setUser(user);
        order.setPlayer(player);
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
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new RuntimeException("订单不存在"));
        return convertToResponse(order);
    }
    
    private String generateOrderNo() {
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
        
        // 设置用户信息
        OrderResponse.UserInfo userInfo = new OrderResponse.UserInfo();
        userInfo.setId(order.getUser().getId());
        userInfo.setUsername(order.getUser().getUsername());
        userInfo.setAvatar(order.getUser().getAvatar());
        response.setUser(userInfo);
        
        // 设置陪玩达人信息
        OrderResponse.PlayerInfo playerInfo = new OrderResponse.PlayerInfo();
        playerInfo.setId(order.getPlayer().getId());
        playerInfo.setUsername(order.getPlayer().getUser().getUsername());
        playerInfo.setAvatar(order.getPlayer().getUser().getAvatar());
        playerInfo.setGame(order.getPlayer().getGame());
        playerInfo.setPrice(order.getPlayer().getServicePrice());
        response.setPlayer(playerInfo);
        
        return response;
    }
}