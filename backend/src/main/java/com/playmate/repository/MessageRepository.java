package com.playmate.repository;

import com.playmate.entity.Message;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MessageRepository extends JpaRepository<Message, Long> {
    
    /**
     * 获取对话中的消息
     */
    @Query("SELECT m FROM Message m WHERE m.conversationId = :conversationId ORDER BY m.createdAt ASC")
    List<Message> findByConversationIdOrderByCreatedAtAsc(@Param("conversationId") String conversationId);
    
    /**
     * 获取用户的所有对话
     */
    @Query("SELECT DISTINCT m.conversationId FROM Message m WHERE m.senderId = :userId OR m.recipientId = :userId")
    List<String> findConversationIdsByUserId(@Param("userId") Long userId);
    
    /**
     * 获取未读消息数量
     */
    @Query("SELECT COUNT(m) FROM Message m WHERE m.recipientId = :userId AND m.isRead = false")
    Long countUnreadMessagesByUserId(@Param("userId") Long userId);
    
    /**
     * 标记消息为已读
     */
    @Query("UPDATE Message m SET m.isRead = true WHERE m.recipientId = :userId AND m.conversationId = :conversationId")
    void markMessagesAsRead(@Param("userId") Long userId, @Param("conversationId") String conversationId);
    
    /**
     * 获取最近的对话
     */
    @Query("SELECT m FROM Message m WHERE m.id IN " +
           "(SELECT MAX(m2.id) FROM Message m2 WHERE m2.conversationId IN " +
           "(SELECT DISTINCT m3.conversationId FROM Message m3 WHERE m3.senderId = :userId OR m3.recipientId = :userId) " +
           "GROUP BY m2.conversationId) ORDER BY m.createdAt DESC")
    List<Message> findLastMessagesInConversations(@Param("userId") Long userId);
}