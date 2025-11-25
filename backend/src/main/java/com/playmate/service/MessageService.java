package com.playmate.service;

import com.playmate.entity.Message;
import com.playmate.repository.MessageRepository;
import com.playmate.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Objects;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class MessageService {

    private final MessageRepository messageRepository;
    private final UserRepository userRepository;

    /**
     * 发送消息
     */
    public Message sendMessage(@NonNull Long senderId, @NonNull Long recipientId, @NonNull String content, @NonNull Message.MessageType type) {
        // 验证发送者和接收者
        userRepository.findById(senderId)
                .orElseThrow(() -> new RuntimeException("发送者不存在"));
        userRepository.findById(recipientId)
                .orElseThrow(() -> new RuntimeException("接收者不存在"));

        // 生成会话ID
        String conversationId = generateConversationId(senderId, recipientId);

        Message message = new Message();
        message.setConversationId(conversationId);
        message.setSenderId(senderId);
        message.setRecipientId(recipientId);
        message.setContent(content);
        message.setType(type);
        message.setIsRead(false);

        return messageRepository.save(message);
    }

    /**
     * 获取对话消息
     */
    @Transactional(readOnly = true)
    public List<Message> getConversationMessages(String conversationId, Long userId) {
        // 验证用户是否有权限访问该对话
        List<Message> messages = messageRepository.findByConversationIdOrderByCreatedAtAsc(conversationId);
        
        // 检查用户是否是对话参与者
        boolean hasAccess = messages.stream()
                .anyMatch(m -> m.getSenderId().equals(userId) || m.getRecipientId().equals(userId));
        
        if (!hasAccess) {
            throw new RuntimeException("无权限访问该对话");
        }

        return messages;
    }

    /**
     * 获取用户的对话列表
     */
    @Transactional(readOnly = true)
    public List<Message> getUserConversations(Long userId) {
        return messageRepository.findLastMessagesInConversations(userId);
    }

    /**
     * 标记消息为已读
     */
    public void markMessagesAsRead(Long userId, String conversationId) {
        messageRepository.markMessagesAsRead(userId, conversationId);
    }

    /**
     * 获取未读消息数量
     */
    @Transactional(readOnly = true)
    public Long getUnreadMessageCount(Long userId) {
        return messageRepository.countUnreadMessagesByUserId(userId);
    }

    /**
     * 生成会话ID
     */
    private String generateConversationId(Long userId1, Long userId2) {
        // 确保较小的ID在前，保证会话ID的一致性
        if (userId1 < userId2) {
            return userId1 + "_" + userId2;
        } else {
            return userId2 + "_" + userId1;
        }
    }

    /**
     * 发送消息到指定会话
     */
    public Message sendMessageToConversation(String conversationId, @NonNull Long senderId, String content, Message.MessageType type) {
        // 验证发送者
        userRepository.findById(senderId)
                .orElseThrow(() -> new RuntimeException("发送者不存在"));

        // 验证会话是否存在
        List<Message> existingMessages = messageRepository.findByConversationIdOrderByCreatedAtAsc(conversationId);
        if (existingMessages.isEmpty()) {
            throw new RuntimeException("会话不存在");
        }

        // 检查用户是否是对话参与者
        boolean hasAccess = existingMessages.stream()
                .anyMatch(m -> m.getSenderId().equals(senderId) || m.getRecipientId().equals(senderId));
        
        if (!hasAccess) {
            throw new RuntimeException("无权限访问该对话");
        }

        // 确定接收者
        Long recipientId = existingMessages.stream()
                .filter(m -> !m.getSenderId().equals(senderId))
                .findFirst()
                .map(Message::getRecipientId)
                .filter(Objects::nonNull)
                .orElseThrow(() -> new RuntimeException("无法确定消息接收者"));

        Message message = new Message();
        message.setConversationId(conversationId);
        message.setSenderId(senderId);
        message.setRecipientId(recipientId);
        message.setContent(content);
        message.setType(type);
        message.setIsRead(false);

        return messageRepository.save(message);
    }

    /**
     * 创建系统消息
     */
    public Message createSystemMessage(Long recipientId, String content) {
        Message message = new Message();
        message.setConversationId(UUID.randomUUID().toString());
        message.setSenderId(null); // 系统消息没有发送者
        message.setRecipientId(recipientId);
        message.setContent(content);
        message.setType(Message.MessageType.SYSTEM);
        message.setIsRead(false);

        return messageRepository.save(message);
    }
}