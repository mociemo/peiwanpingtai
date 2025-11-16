package com.playmate.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Table(name = "follows", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"follower_id", "following_id"})
})
@Data
public class Follow {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "follower_id", nullable = false)
    private Long followerId;
    
    @Column(name = "following_id", nullable = false)
    private Long followingId;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private FollowStatus status = FollowStatus.FOLLOWING;
    
    @Column(nullable = false)
    private LocalDateTime createTime;
    
    @PrePersist
    protected void onCreate() {
        createTime = LocalDateTime.now();
    }
}