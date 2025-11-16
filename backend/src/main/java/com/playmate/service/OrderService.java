package com.playmate.service;

import com.playmate.dto.CreateOrderRequest;
import com.playmate.dto.OrderResponse;
import com.playmate.entity.Order;
import com.playmate.entity.User;
import com.playmate.repository.OrderRepository;
import com.playmate.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class OrderService {

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private UserRepository userRepository;

    public OrderResponse createOrder(Long userId, CreateOrderRequest request) {
        Order order = new Order();
        order.setUserId(userId.toString());
        order.setPlayerId(request.getPlayerId().toString());
        order.setGameId(request.getGameId());
        order.setServiceType(request.getServiceType());
        order.setDuration(request.getDuration());
        order.setRequirements(request.getRequirements());
        order.setStatus("pending");
        order.setCreateTime(LocalDateTime.now());

        order = orderRepository.save(order);
        return convertToResponse(order);
    }

    public List<OrderResponse> getUserOrders(Long userId) {
        List<Order> orders = orderRepository.findByUserIdOrderByCreateTimeDesc(userId.toString());
        return orders.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public List<OrderResponse> getPlayerOrders(Long playerId) {
        List<Order> orders = orderRepository.findByPlayerIdOrderByCreateTimeDesc(playerId.toString());
        return orders.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public OrderResponse getOrderById(String orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("订单不存在"));
        return convertToResponse(order);
    }

    public OrderResponse acceptOrder(String orderId, Long playerId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("订单不存在"));
        order.setPlayerId(playerId.toString());
        order.setStatus("accepted");
        order = orderRepository.save(order);
        return convertToResponse(order);
    }

    public OrderResponse startOrder(String orderId, Long playerId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("订单不存在"));
        if (!order.getPlayerId().equals(playerId.toString())) {
            throw new RuntimeException("无权操作此订单");
        }
        order.setStatus("in_progress");
        order = orderRepository.save(order);
        return convertToResponse(order);
    }

    public OrderResponse completeOrder(String orderId, Long playerId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("订单不存在"));
        if (!order.getPlayerId().equals(playerId.toString())) {
            throw new RuntimeException("无权操作此订单");
        }
        order.setStatus("completed");
        order = orderRepository.save(order);
        return convertToResponse(order);
    }

    public OrderResponse cancelOrder(String orderId, Long userId, String reason) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("订单不存在"));
        if (!order.getUserId().equals(userId.toString())) {
            throw new RuntimeException("无权取消此订单");
        }
        order.setStatus("cancelled");
        order.setCancelReason(reason);
        order = orderRepository.save(order);
        return convertToResponse(order);
    }

    public OrderResponse rateOrder(String orderId, Long userId, String rating, String comment) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("订单不存在"));
        if (!order.getUserId().equals(userId.toString())) {
            throw new RuntimeException("无权评价此订单");
        }
        order.setRating(rating);
        order.setComment(comment);
        order.setCommentTime(LocalDateTime.now());
        order = orderRepository.save(order);
        return convertToResponse(order);
    }

    public OrderResponse updateOrderStatus(String orderId, String status) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("订单不存在"));
        order.setStatus(status);
        order = orderRepository.save(order);
        return convertToResponse(order);
    }

    private OrderResponse convertToResponse(Order order) {
        OrderResponse response = new OrderResponse();
        response.setId(Long.valueOf(order.getId()));
        response.setUserId(order.getUserId());
        response.setPlayerId(order.getPlayerId());
        response.setGameId(order.getGameId());
        response.setServiceType(order.getServiceType());
        response.setDuration(order.getDuration());
        response.setRequirements(order.getRequirements());
        response.setStatus(order.getStatus());
        response.setCreateTime(order.getCreateTime());
        return response;
    }
}