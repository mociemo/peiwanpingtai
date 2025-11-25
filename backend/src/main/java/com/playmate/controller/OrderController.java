package com.playmate.controller;

import com.playmate.dto.ApiResponse;
import com.playmate.dto.CreateOrderRequest;
import com.playmate.dto.OrderResponse;
import com.playmate.entity.User;
import com.playmate.service.OrderService;
import com.playmate.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.lang.NonNull;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {
    
    private final OrderService orderService;
    private final UserService userService;
    
    @PostMapping
    public ResponseEntity<ApiResponse<OrderResponse>> createOrder(
            @NonNull @RequestBody CreateOrderRequest request,
            Authentication authentication) {
        try {
            String username = authentication.getName();
            User user = userService.findByUsername(username)
                    .orElseThrow(() -> new RuntimeException("用户不存在"));
            Long userId = user.getId();
            if (userId == null) {
                throw new IllegalStateException("用户ID不能为空");
            }
            OrderResponse order = orderService.createOrder(userId, request);
            return ResponseEntity.ok(ApiResponse.success("订单创建成功", order));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @GetMapping("/user")
    public ResponseEntity<ApiResponse<List<OrderResponse>>> getUserOrders(Authentication authentication) {
        try {
            String username = authentication.getName();
            User user = userService.findByUsername(username)
                    .orElseThrow(() -> new RuntimeException("用户不存在"));
            Long userId = user.getId();
            if (userId == null) {
                throw new IllegalStateException("用户ID不能为空");
            }
            List<OrderResponse> orders = orderService.getUserOrders(userId);
            return ResponseEntity.ok(ApiResponse.success("获取订单列表成功", orders));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @GetMapping("/player")
    public ResponseEntity<ApiResponse<List<OrderResponse>>> getPlayerOrders(Authentication authentication) {
        try {
            String username = authentication.getName();
            Long playerId = userService.findByUsername(username)
                    .orElseThrow(() -> new RuntimeException("用户不存在"))
                    .getId();
            List<OrderResponse> orders = orderService.getPlayerOrders(playerId);
            return ResponseEntity.ok(ApiResponse.success("获取订单列表成功", orders));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @GetMapping("/{orderId}")
    public ResponseEntity<ApiResponse<OrderResponse>> getOrderById(@PathVariable Long orderId) {
        try {
            OrderResponse order = orderService.getOrderById(orderId);
            return ResponseEntity.ok(ApiResponse.success("获取订单详情成功", order));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PostMapping("/{orderId}/accept")
    public ResponseEntity<ApiResponse<OrderResponse>> acceptOrder(
            @PathVariable Long orderId,
            Authentication authentication) {
        try {
            String username = authentication.getName();
            Long playerId = userService.findByUsername(username)
                    .orElseThrow(() -> new RuntimeException("用户不存在"))
                    .getId();
            OrderResponse order = orderService.acceptOrder(orderId, playerId);
            return ResponseEntity.ok(ApiResponse.success("接单成功", order));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PostMapping("/{orderId}/start")
    public ResponseEntity<ApiResponse<OrderResponse>> startOrder(
            @PathVariable Long orderId,
            Authentication authentication) {
        try {
            String username = authentication.getName();
            Long playerId = userService.findByUsername(username)
                    .orElseThrow(() -> new RuntimeException("用户不存在"))
                    .getId();
            OrderResponse order = orderService.startOrder(orderId, playerId);
            return ResponseEntity.ok(ApiResponse.success("开始服务成功", order));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PostMapping("/{orderId}/complete")
    public ResponseEntity<ApiResponse<OrderResponse>> completeOrder(
            @PathVariable Long orderId,
            Authentication authentication) {
        try {
            String username = authentication.getName();
            Long playerId = userService.findByUsername(username)
                    .orElseThrow(() -> new RuntimeException("用户不存在"))
                    .getId();
            OrderResponse order = orderService.completeOrder(orderId, playerId);
            return ResponseEntity.ok(ApiResponse.success("完成服务成功", order));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PostMapping("/{orderId}/cancel")
    public ResponseEntity<ApiResponse<OrderResponse>> cancelOrder(
            @PathVariable Long orderId,
            @RequestParam String reason,
            Authentication authentication) {
        try {
            String username = authentication.getName();
            User user = userService.findByUsername(username)
                    .orElseThrow(() -> new RuntimeException("用户不存在"));
            Long userId = user.getId();
            if (userId == null) {
                throw new IllegalStateException("用户ID不能为空");
            }
            OrderResponse order = orderService.cancelOrder(orderId, userId, reason);
            return ResponseEntity.ok(ApiResponse.success("取消订单成功", order));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PostMapping("/{orderId}/rate")
    public ResponseEntity<ApiResponse<OrderResponse>> rateOrder(
            @PathVariable Long orderId,
            @RequestParam String rating,
            @RequestParam(required = false) String comment,
            Authentication authentication) {
        try {
            String username = authentication.getName();
            User user = userService.findByUsername(username)
                    .orElseThrow(() -> new RuntimeException("用户不存在"));
            Long userId = user.getId();
            if (userId == null) {
                throw new IllegalStateException("用户ID不能为空");
            }
            OrderResponse order = orderService.rateOrder(orderId, userId, rating, comment);
            return ResponseEntity.ok(ApiResponse.success("评价成功", order));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
}