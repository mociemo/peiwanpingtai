package com.playmate.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import java.time.LocalDateTime;

@Document(collection = "comments")
public class Comment {
    
    @Id
    private String id;
    
    private String postId;
    
    private String userId;
    
    private String content;
    
    private String parentId;
    
    private String replyToUserId;
    
    private CommentStatus status = CommentStatus.PUBLISHED;
    
    private Integer likeCount = 0;
    
    private LocalDateTime createTime;
    
    // Manual getters and setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    
    public String getPostId() { return postId; }
    public void setPostId(String postId) { this.postId = postId; }
    
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    
    public String getParentId() { return parentId; }
    public void setParentId(String parentId) { this.parentId = parentId; }
    
    public String getReplyToUserId() { return replyToUserId; }
    public void setReplyToUserId(String replyToUserId) { this.replyToUserId = replyToUserId; }
    
    public CommentStatus getStatus() { return status; }
    public void setStatus(CommentStatus status) { this.status = status; }
    
    public Integer getLikeCount() { return likeCount; }
    public void setLikeCount(Integer likeCount) { this.likeCount = likeCount; }
    
    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }
}