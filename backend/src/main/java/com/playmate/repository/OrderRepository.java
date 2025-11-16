package com.playmate.repository;

import com.playmate.entity.Order;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OrderRepository extends MongoRepository<Order, String> {
    
    List<Order> findByUserIdOrderByCreateTimeDesc(String userId);
    
    List<Order> findByPlayerIdOrderByCreateTimeDesc(String playerId);
    
    List<Order> findByUserIdAndStatus(String userId, String status);
}